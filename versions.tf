terraform {
  required_version = ">= 0.13"
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.10.0"
    }
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.2"
    }
    http = {
      source = "hashicorp/http"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
