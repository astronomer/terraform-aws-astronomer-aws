/*
This lambda is used to dynamically
find the name of the ELB, since an
appropriate terraform data source
does not exist (look up ELB by vpc / tags)
*/

resource random_id "collision_avoidance" {
  byte_length = 5
}

# This data source will be used in other files
resource "aws_iam_role_policy" "elb_lookup_policy" {

  name = "${var.deployment_id}_elb_lookup_policy${random_id.collision_avoidance.hex}"
  role = "${aws_iam_role.elb_lookup_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Action": ["elasticloadbalancing:DescribeLoadBalancers",
                 "elasticloadbalancing:DescribeTags"],
      "Effect": "Allow",
      "Resource": "*"
    }]
}
EOF
}

resource "aws_iam_role" "elb_lookup_role" {
  name = "${var.deployment_id}_elb_lookup_role${random_id.collision_avoidance.hex}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

tags = local.tags
}

data "archive_file" "elb_lookup" {
  type        = "zip"
  source_file = "${path.module}/files/elb_lookup.py"
  output_path = "${path.module}/elb_lookup.py.zip"
}

resource "aws_lambda_function" "elb_lookup" {
  depends_on       = ["data.archive_file.elb_lookup"]
  filename         = "${path.module}/elb_lookup.py.zip"
  function_name    = "${var.deployment_id}_elb_lookup_function${random_id.collision_avoidance.hex}"
  role             = "${aws_iam_role.elb_lookup_role.arn}"
  handler          = "elb_lookup.my_handler"
  source_code_hash = "${data.archive_file.elb_lookup.output_base64sha256}"
  runtime          = "python3.7"

  environment {
    variables = {
      VPC_ID       = "${local.vpc_id}"
      CLUSTER_NAME = "${local.cluster_name}"
    }
  }

  tags = local.tags
}
