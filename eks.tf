# Create the EKS cluster
resource "aws_key_pair" "worker_group_key_name" {
  count      = var.pub_key_for_worker_aws_key_pair != "" ? 1 : 0
  public_key = var.pub_key_for_worker_aws_key_pair
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# for the eks module to work properly, we need
# to specify the authentication for this provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks" {
  # Until the 0.12 support PRs are merged, we use a local
  # copy of the pending PRs
  source = "terraform-aws-modules/eks/aws"
  # version of the eks module to use
  version = "13.2.1"
  # source = "./modules/terraform-aws-eks"

  cluster_name           = local.cluster_name
  cluster_version        = var.cluster_version
  cluster_create_timeout = "30m"

  subnets = local.private_subnets

  vpc_id = local.vpc_id

  worker_groups = [
    {
      name                 = "${var.deployment_id}-worker-nodes"
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.min_cluster_size
      asg_min_size         = var.min_cluster_size
      asg_max_size         = var.max_cluster_size
      key_name             = var.pub_key_for_worker_aws_key_pair != "" ? aws_key_pair.worker_group_key_name[0].key_name : ""
      autoscaling_enabled  = true
    },
  ]

  cluster_endpoint_private_access = "true"

  cluster_endpoint_public_access = var.management_api == "public" ? true : false

  manage_aws_auth = true

  tags = local.tags
}
