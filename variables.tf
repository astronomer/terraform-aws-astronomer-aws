# Variables Configuration
#
variable "cluster_type" {
  default = "private"
  type    = "string"
}

# this is the basename that will be used
# for naming other things
variable "deployment_id" {
  description = "this lowercase, letters-only string will be used to prefix some of your AWS resources."
  type        = "string"
}

variable "route53_domain" {
  description = "The route53 domain in your account you want to use for the *.<deployment_id>.<route53_domain> subdomain"
  type        = "string"
}

variable "cluster_version" {
  default = "1.12"
  type    = "string"
}

variable "admin_email" {
  description = "An email address that will be used to create the let's encrypt cert"
  type        = "string"
}

variable "postgres_airflow_password" {
  default     = ""
  description = "The password for the 'airflow' user in postgres. If blank, will be auto-generated"
  type        = "string"
}

variable "aws_region" {
  default = "us-east-1"
  type    = "string"
}

variable "max_cluster_size" {
  default = "8"
  type    = "string"
}

variable "min_cluster_size" {
  default = "4"
  type    = "string"
}

variable "worker_instance_type" {
  default = "m5.xlarge"
  type    = "string"
}

variable "db_instance_type" {
  default = "db.r4.large"
  type    = "string"
}

variable "bastion_instance_type" {
  default = "t2.micro"
  type = "string"
}

variable "management_api" {
  default = "private"
  type    = "string"
}

variable "acme_server" {
  # default = "https://acme-staging-v02.api.letsencrypt.org/directory"
  default = "https://acme-v02.api.letsencrypt.org/directory"
  type    = "string"
}

variable "ten_dot_what_cidr" {
  description = "10.X.0.0/16 - choose X"

  # This is probably not that common
  default = "234"
  type    = "string"
}
