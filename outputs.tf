output "bastion_ssh_command" {
  value = "ssh -i ${local_file.bastion_ssh_key_private.filename} ubuntu@${aws_instance.bastion.public_ip}"
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
