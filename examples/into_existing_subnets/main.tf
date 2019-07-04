variable deployment_id {}

# This is a sample vpc configuration
# you may choose to use your own, existing
# VPC.
module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = "2.5.0"

  name = "simple-example"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

}

# this is how the module can be called if you
# want to deploy into a set of existing, private subnets
module "astronomer_aws_in_specific_subnet" {
  # same idea above - use a different 'source', and specify 'version'
  source         = "../.."
  deployment_id  = var.deployment_id
  admin_email    = "steven@astronomer.io"
  route53_domain = "astronomer-development.com"
  management_api = "public"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}
