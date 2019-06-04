/*
Wildcard SSL certificate
created with Let's Encrypt
and AWS Route 53
*/

resource "tls_private_key" "nginx_key" {
  algorithm = "RSA"
}

resource "acme_registration" "user_registration" {
  account_key_pem = "${tls_private_key.nginx_key.private_key_pem}"
  email_address   = "${var.admin_email}"
}

resource "acme_certificate" "lets_encrypt" {
  account_key_pem = "${acme_registration.user_registration.account_key_pem}"
  common_name     = "*.${var.deployment_id}.${var.route53_domain}"

  dns_challenge {
    provider = "route53"
  }
}
