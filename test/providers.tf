provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "aws" {
  region  = "us-east-1"
}

