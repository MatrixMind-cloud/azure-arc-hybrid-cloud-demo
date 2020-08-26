terraform {
  required_providers {
    aws = "~> 2.64"
    tls = "~> 2.1"
  }
  required_version = "~> 0.12"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
