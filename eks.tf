# Create the EKS cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # version of the eks module to use
  version = "3.0.0"

  cluster_name    = "${local.cluster_name}"
  cluster_version = "${var.cluster_version}"

  subnets       = ["${module.vpc.private_subnets}"]
  tags          = "${local.tags}"
  vpc_id        = "${module.vpc.vpc_id}"

  worker_groups = [
    {
      instance_type        = "${var.worker_instance_type}"
      subnets              = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = "${var.min_cluster_size}"
      asg_min_size         = "${var.min_cluster_size}"
      asg_max_size         = "${var.max_cluster_size}"
    }
  ]

  # We are not using the 'launch templates' feature at this time
  # this is a feature for deploying workers on Spot instances.
  # worker_groups_launch_template        = "${local.worker_groups_launch_template}"

  worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]

  map_roles = []

  map_accounts                    = []
  map_users                       = []
  cluster_endpoint_private_access = "true"

  cluster_endpoint_public_access = "${var.management_api == "public" ? true : false}"

  map_roles_count                = "0"
  map_users_count                = "0"
  map_accounts_count             = "0"

  worker_group_count = "1"
  worker_group_launch_template_count = "0"
}
