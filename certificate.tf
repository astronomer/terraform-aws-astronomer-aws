/*
Wildcard SSL certificate
created with Let's Encrypt
and AWS Route 53
*/

resource "tls_private_key" "lets_encrypt_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "user_registration" {
  count = var.lets_encrypt ? 1 : 0

  account_key_pem = tls_private_key.lets_encrypt_private_key.private_key_pem
  email_address   = var.admin_email
}

resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "req" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.cert_private_key.private_key_pem
  dns_names       = ["*.${var.deployment_id}.${var.route53_domain}"]

  subject {
    common_name  = "*.${var.deployment_id}.${var.route53_domain}"
    organization = "Astronomer"
  }
}

resource "acme_certificate" "lets_encrypt" {
  count = var.lets_encrypt ? 1 : 0

  account_key_pem         = acme_registration.user_registration[0].account_key_pem
  certificate_request_pem = tls_cert_request.req.cert_request_pem
  recursive_nameservers   = ["8.8.8.8:53", "8.8.4.4:53"]

  dns_challenge {
    provider = "route53"
    config = {
      AWS_PROPAGATION_TIMEOUT = 900
    }
  }
}
