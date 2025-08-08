variable "hcloud_api_token" {
  description = "API token for Hetzner Cloud"
  type        = string
  sensitive = true
}

variable "default_domain" {
  description = "Default domain"
  type        = string
  default     = "terraform.test"
}


variable "default_datacenter" {
  description = "Default datacenter"
  type        = string
  default     = "nbg1-dc3"
}

variable "default_network_zone" {
  description = "Default network zone"
  type        = string
  default     = "eu-central"
}

variable "new_ssh_keys" {
  description = "SSH keys to add to the server"
  type        = map(string)
  default     = {}
}

variable "hetzner_vms" {
  description = "List of VMs to create"
  type = list(object({
    name = string
    domain   = optional(string)
    type = string
    labels = optional(map(string))
    image       = string
    datacenter    = optional(string)
    ipv6_enabled = optional(bool)

    enable_existing_ssh_keys = optional(bool)
    new_ssh_keys = optional(map(string))

    network_id         = optional(string)
    network_ip         = optional(string)
    network_ip_aliases = optional(list(string))

    ansible_name   = optional(string)
    ansible_host   = optional(string)
    ansible_user   = optional(string)
    ansible_ssh_pass = optional(string)
    ansible_groups = optional(list(string))
  }))
  default = []
}

variable "hetzner_lbs" {
  description = "List of Load Balancers to create"
  type = list(object({
    name = string
    domain = optional(string)
    location = optional(string)
    network_zone = optional(string)
    datacenter = optional(string)
    targets = list(object({
      type = string
      selector = string
    }))
    services = list(object({
      protocol = string
      listen_port = number
      destination_port = number
      proxy_protocol = optional(bool)
      http = optional(object({
        sticky_sessions = bool
        cookie_name     = optional(string)
        cookie_lifetime = optional(number)
        certficates     = optional(list(string))
        redirect_http   = optional(bool)
      }))
      healthcheck = optional(object({
        protocol                 = optional(string)
        port                     = optional(number)
        interval                = optional(number)
        timeout                = optional(number)
        retries               = optional(number)
        http                   = optional(object({
          domain       = optional(string)
          path         = optional(string)
          response     = optional(string)
          tls          = optional(bool)
          status_codes = optional(list(string))
        }))
      }))
    }))
  }))
  default = []
}

variable "additional_dns_records" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}
