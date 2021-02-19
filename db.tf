resource "random_id" "db_name_suffix" {
  byte_length = 8
}

resource "random_string" "postgres_airflow_password" {
  count   = var.postgres_airflow_password == "" ? 1 : 0
  length  = 32
  special = false
}

module "aurora" {
  # does not support Terraform 0.12 in registry, but there was a PR
  # that I copied locally.
  version = "2.29.0"
  source  = "terraform-aws-modules/rds-aurora/aws"
  # source         = "./modules/terraform-aws-rds-aurora"
  name   = "astrodb-${random_id.db_name_suffix.hex}"
  engine = "aurora-postgresql"

  engine_version             = var.engine_version
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  subnets = local.database_subnets
  vpc_id  = local.vpc_id

  replica_count                   = var.db_replica_count
  instance_type                   = var.db_instance_type
  apply_immediately               = true
  skip_final_snapshot             = false
  db_parameter_group_name         = aws_db_parameter_group.aurora_db_postgres_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_postgres_parameter_group.id

  # NOTE: This is only supported by Aurora for MySQL
  # enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  enabled_cloudwatch_logs_exports = []

  username            = "airflow"
  password            = local.postgres_airflow_password
  publicly_accessible = false

  tags = local.tags
}

resource "aws_db_parameter_group" "aurora_db_postgres_parameter_group" {
  name        = "${var.deployment_id}-aurora-db-postgres-parameter-group-${random_id.db_name_suffix.hex}"
  family      = local.db_parameter_group_family
  description = "${var.deployment_id}-aurora-db-postgres-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres_parameter_group" {
  name        = "${var.deployment_id}-aurora-postgres-cluster-parameter-group-${random_id.db_name_suffix.hex}"
  family      = local.db_parameter_group_family
  description = "${var.deployment_id}-aurora-postgres-cluster-parameter-group"
  tags        = local.tags
}

# this permission is used to validate the connection
resource "aws_security_group_rule" "allow_access_from_bastion" {
  count                    = var.enable_bastion ? 1 : 0
  type                     = "ingress"
  from_port                = module.aurora.this_rds_cluster_port
  to_port                  = module.aurora.this_rds_cluster_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg[0].id
  security_group_id        = module.aurora.this_security_group_id
}

resource "aws_security_group_rule" "allow_access_from_eks_workers" {
  type                     = "ingress"
  from_port                = module.aurora.this_rds_cluster_port
  to_port                  = module.aurora.this_rds_cluster_port
  protocol                 = "tcp"
  source_security_group_id = module.eks.worker_security_group_id
  security_group_id        = module.aurora.this_security_group_id
}
