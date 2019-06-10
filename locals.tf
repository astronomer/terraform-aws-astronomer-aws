resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "${var.deployment_id}-astronomer-${random_string.suffix.result}"

  postgres_airflow_password = var.postgres_airflow_password == "" ? random_string.postgres_airflow_password[0].result : var.postgres_airflow_password

  azs = ["${var.aws_region}a", "${var.aws_region}b"]

  tags = {}
}

