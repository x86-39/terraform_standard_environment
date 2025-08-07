terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.61.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_api_token
}