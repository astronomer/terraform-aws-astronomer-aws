output "kubernetes_api_sample_command" {
  value = "If you have started the api proxy using the bastion SOCKS5 proxy command, this should work:\nhttps_proxy=socks5://127.0.0.1:1234 kubectl get pods"
}

output "kubeconfig" {
  value     = module.eks.kubeconfig
  sensitive = true
}

output "base_domain" {
  value = "${var.deployment_id}.${var.route53_domain}"
}

output "kubeconfig_filename" {
  value = module.eks.kubeconfig_filename
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "db_connection_string" {
  value     = "postgres://${module.aurora.this_rds_cluster_master_username}:${module.aurora.this_rds_cluster_master_password}@${module.aurora.this_rds_cluster_endpoint}:${module.aurora.this_rds_cluster_port}"
  sensitive = true
}

output "tls_key" {
  value     = tls_private_key.cert_private_key.private_key_pem
  sensitive = true
}

output "tls_cert" {
  value     = ! var.lets_encrypt ? "Not applicable - lets_encrypt is not enabled." : <<EOF
${acme_certificate.lets_encrypt[0].certificate_pem}
${acme_certificate.lets_encrypt[0].issuer_pem}
EOF
  sensitive = true
}

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnets" {
  value = local.private_subnets
}

output "elb_lookup_function_name" {
  value = aws_lambda_function.elb_lookup.function_name
}

# https://github.com/hashicorp/terraform/issues/1178
resource "null_resource" "dependency_setter" {}
output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}

output "windows_debug_box_password" {
  value = var.enable_windows_box ? "${rsadecrypt(aws_instance.windows_debug_box[0].password_data, tls_private_key.ssh_key[0].private_key_pem)}" : "Not applicable - Windows box is not enabled."
}

output "windows_debug_box_hostname" {
  value = var.enable_windows_box ? aws_instance.windows_debug_box[0].public_dns : "Not applicable - Windows box is not enabled."
}
