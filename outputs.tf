output "bastion_socks5_proxy_command" {
  value = "ssh -i ${local_file.bastion_ssh_key_private.filename} ubuntu@${aws_instance.bastion.public_ip} -D 1234 -C -N"
}

output "kubernetes_api_sample_command" {
  value = "If you have started the api proxy using the bastion SOCKS5 proxy command, this should work:\nhttps_proxy=socks5://127.0.0.1:1234 kubectl get pods"
}

output "kubeconfig" {
  value = "${module.eks.kubeconfig}"
  sensitive = true
}

/*
output "db_connection_string" {
  value = "postgres://${google_sql_user.airflow.name}:${local.postgres_airflow_password}@${google_sql_database_instance.instance.private_ip_address}:5432"
  sensitive = true
}
*/

output "tls_key" {
  value = "${acme_certificate.lets_encrypt.private_key_pem}"
  sensitive = true
}

output "tls_cert" {
  value = "${acme_certificate.lets_encrypt.certificate_pem}"
  sensitive = true
}
