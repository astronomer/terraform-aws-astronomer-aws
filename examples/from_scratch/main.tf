provider "aws" {
  region = "us-east-1"
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

# This resource is just to enable us to
# run multiple pipelines at the same time.
# It randomizes the deployment_id, an argument
# specifically designed for the case of collision
# avoidance and labeling.
resource random_id "ci_collision_avoidance" {
  byte_length = 4
}

# this is how the module can be called 
# if you want to create a VPC and the subnets
# from scratch.
module "astronomer_aws_with_vpc" {
  source = "../.."
  # you should use the following commented lines, not
  # the above "../.." if you want to consume this remotely
  # source  = "astronomer/astronomer-aws/aws"
  # version = "<fill me in>" # Look here https://registry.terraform.io/modules/astronomer/astronomer-aws/aws
  deployment_id  = "fromscratchci${random_id.ci_collision_avoidance.hex}"
  admin_email    = "steven@astronomer.io"
  route53_domain = "astronomer-development.com"
  management_api = "public"
}
