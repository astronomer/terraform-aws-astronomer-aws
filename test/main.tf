# this is how the module can be called 
# if you want to create a VPC and the subnets
# from scratch.
module "astronomer_aws_with_vpc" {
  source  = "../"
  # you should use the following commented lines, not
  # the above "../" if you want to consume this remotely
  # source  = "astronomer/astronomer-aws/aws"
  # version = "<fill me in>" # Look here https://registry.terraform.io/modules/astronomer/astronomer-aws/aws
  deployment_id = "test1"
  admin_email = "steven@astronomer.io"
  route53_domain = "steven-development.com"
}

# this is how the module can be called if you
# want to deploy into a set of existing, private subnets
module "astronomer_aws_in_specific_subnet" {
  # same idea above - use a different 'source', and specify 'version'
  source  = "../"
  deployment_id = "test2"
  admin_email = "steven@astronomer.io"
  route53_domain = "steven-development.com"
  vpc_id = module.astronomer_aws_with_vpc.vpc_id
  private_subnets = module.astronomer_aws_with_vpc.private_subnets
  management_api = "public"
}
