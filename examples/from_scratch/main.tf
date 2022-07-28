variable "deployment_id" {}

# this is how the module can be called
# if you want to create a VPC and the subnets
# from scratch.
module "astronomer_aws_with_vpc" {
  source = "../.."
  # you should use the following commented lines, not
  # the above "../.." if you want to consume this remotely
  # source  = "astronomer/astronomer-aws/aws"
  # version = "<fill me in>" # Look here https://registry.terraform.io/modules/astronomer/astronomer-aws/aws
  deployment_id      = var.deployment_id
  admin_email        = "infrastructure@astronomer.io"
  route53_domain     = "astro-qa.com"
  management_api     = "public"
  enable_bastion     = true
  enable_windows_box = true
  tags = {
    "CI" = "true"
  }
}

resource "local_sensitive_file" "kubeconfig" {
  depends_on = [module.astronomer_aws_with_vpc]
  content    = module.astronomer_aws_with_vpc.kubeconfig
  filename   = "${path.root}/kubeconfig-${var.deployment_id}"
}

terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
    }
  }
  required_version = ">= 0.13"
}
