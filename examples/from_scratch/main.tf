variable "deployment_id" {}

provider "aws" {
  region = "ap-southeast-1"
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
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
  deployment_id      = var.deployment_id
  admin_email        = "steven@astronomer.io"
  route53_domain     = "sreteam090.sreteam002.astro-qa.link"
  management_api     = "public"
  enable_bastion     = false
  enable_windows_box = false
  tags = {
    "CI" = "true"
  }
}

resource "local_file" "kubeconfig" {
  depends_on = [module.astronomer_aws_with_vpc]
  content    = module.astronomer_aws_with_vpc.kubeconfig
  filename   = "${path.root}/kubeconfig-${var.deployment_id}"
}

terraform {
  required_providers {
    acme = {
      source = "terraform-providers/acme"
    }
  }
  required_version = ">= 0.13"
}
