output "bastion_socks5_proxy_command" {
  value = "ssh -i ${local_file.bastion_ssh_key_private[0].filename} ubuntu@${aws_instance.bastion[0].public_ip} -D 1234 -C -N"
}

output "kubernetes_api_sample_command" {
  value = "If you have started the api proxy using the bastion SOCKS5 proxy command, this should work:\nhttps_proxy=socks5://127.0.0.1:1234 kubectl get pods"
}

output "kubeconfig" {
  value     = module.eks.kubeconfig
  sensitive = true
}

output "kubeconfig_filename" {
  value     = module.eks.kubeconfig_filename
}

output "db_connection_string" {
  value     = "postgres://${module.aurora.this_rds_cluster_master_username}:${module.aurora.this_rds_cluster_master_password}@${module.aurora.this_rds_cluster_endpoint}:${module.aurora.this_rds_cluster_port}"
  sensitive = true
}

output "tls_key" {
  value     = acme_certificate.lets_encrypt.private_key_pem
  sensitive = true
}

output "tls_cert" {
  value     = acme_certificate.lets_encrypt.certificate_pem
  sensitive = true
}

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnets" {
  value = local.private_subnets
}
