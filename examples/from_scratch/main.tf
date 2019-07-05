variable deployment_id {}

# this is how the module can be called 
# if you want to create a VPC and the subnets
# from scratch.
module "astronomer_aws_with_vpc" {
  source = "../.."
  # you should use the following commented lines, not
  # the above "../.." if you want to consume this remotely
  # source  = "astronomer/astronomer-aws/aws"
  # version = "<fill me in>" # Look here https://registry.terraform.io/modules/astronomer/astronomer-aws/aws
  deployment_id  = var.deployment_id
  admin_email    = "steven@astronomer.io"
  route53_domain = "astronomer-development.com"
  management_api = "public"
}
