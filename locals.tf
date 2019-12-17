resource "random_string" "suffix" {
  length  = 8
  special = false
}

data aws_region current {}

locals {
  cluster_name = "astronomer-${random_string.suffix.result}"

  postgres_airflow_password = var.postgres_airflow_password == "" ? random_string.postgres_airflow_password[0].result : var.postgres_airflow_password

  azs = ["${local.region}a", "${local.region}b"]

  vpc_id = var.vpc_id == "" ? module.vpc.vpc_id : var.vpc_id

  private_subnets = var.vpc_id == "" ? module.vpc.private_subnets : var.private_subnets

  bring_your_own_db_subnets = length(var.db_subnets) > 0 ? var.db_subnets : local.private_subnets

  database_subnets = var.vpc_id == "" ? module.vpc.database_subnets : local.bring_your_own_db_subnets

  public_subnets = var.vpc_id == "" ? module.vpc.public_subnets : var.public_subnets

  region = data.aws_region.current.name

  tags = merge(
    var.tags,
    map(
      "Deployment ID", var.deployment_id
    )
  )
}
