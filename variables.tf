# Variables Configuration
#

# this is the basename that will be used
# for naming other things
variable "deployment_id" {
  description = "this lowercase, letters-only string will be used to prefix some of your AWS resources."
  type        = string
}

variable "allow_public_load_balancers" {
  description = "Configuring this variable will allow for public load balancers to be created in the Kubernetes."
  default     = false
  type        = bool
}

variable "route53_domain" {
  description = "The route53 domain in your account you want to use for the *.<deployment_id>.<route53_domain> subdomain"
  type        = string
}

variable "admin_email" {
  description = "An email address that will be used to create the let's encrypt cert"
  type        = string
}

variable "cluster_version" {
  default = "1.14"
  type    = string
}

variable "vpc_id" {
  default     = ""
  type        = string
  description = "The VPC ID, in the case that you do not want terraform to create a VPC with the default network settings on your behalf. If this setting is present, you should also have at least a 2 other subnets, each in a different availability zone, in the same region specified in aws_region."
}

variable "private_subnets" {
  default     = []
  type        = list
  description = "This variable does nothing unless vpc_id is also set. Specify the subnet IDs in which the platform will be deployed"
}

variable "db_subnets" {
  default     = []
  type        = list
  description = "This variable does nothing unless vpc_id is also set. Specify the subnet IDs in which the DB will be deployed. If not provided, it will fall back to private_subnets."
}

variable "public_subnets" {
  default     = []
  type        = list
  description = "This variable does nothing unless vpc_id is also set. Specify the subnet ID(s) (you probably only want one) in the bastion will be deployed. This is not needed unless you are enabling the bastion host."
}

variable "postgres_airflow_password" {
  default     = ""
  description = "The password for the 'airflow' user in postgres. If blank, will be auto-generated"
  type        = string
}

variable "max_cluster_size" {
  default = "8"
  type    = string
}

variable "min_cluster_size" {
  default = "4"
  type    = string
}

variable "worker_instance_type" {
  default = "m5.xlarge"
  type    = string
}

variable "pub_key_for_worker_aws_key_pair" {
  default = ""
  type    = string
}

variable "db_instance_type" {
  default = "db.r4.large"
  type    = string
}

variable "enable_bastion" {
  default = false
  type    = string
}

variable "enable_windows_box" {
  default = false
  type    = string
}

variable "bastion_instance_type" {
  default = "t2.micro"
  type    = string
}

variable "management_api" {
  default = "private"
  type    = string
}

variable "ten_dot_what_cidr" {
  description = "10.X.0.0/16 - choose X. This does nothing in the case that you specify vpc_id variable."

  # This is probably not that common
  default = "234"
  type    = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "peer_vpc_id" {
  default = ""
  type    = string
}

variable "peer_account_id" {
  default = ""
  type    = string
}

variable "bastion_astro_cli_version" {
  default     = "v0.10.3"
  type        = string
  description = "The version of astro-cli to install on the bastion host"
}

variable "extra_sg_ids_for_eks_security" {
  description = "A list of security groups that you want to add in security access to private eks cluster"
  default     = []
  type        = list
}

variable "lets_encrypt" {
  type    = bool
  default = true
}

variable "db_replica_count" {
  description = "How many replicas for the database"
  default     = 1
  type        = number
}

variable "local_ip" {
  description = "URL used to find user's local IP for use with bastion host"
  default     = "http://ipv4.icanhazip.com"
  type        = string
}

variable "engine_version" {
  description = "Aurora database engine version."
  type        = string
  default     = "10.7"
}

variable "auto_minor_version_upgrade" {
  description = "Determines whether minor engine upgrades for Aurora RDS will be performed automatically in the maintenance window"
  type        = bool
  default     = false
}
