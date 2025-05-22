terraform {
  required_version = ">= 1.4"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.54.0"
    }
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_api_token
}