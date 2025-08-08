variable "default_domain" {
  description = "Default domain"
  type        = string
  default     = "terraform.test"
}

variable "default_region" {
  description = "Default region"
  type        = string
  default     = "ams3"
}

variable "default_project" {
  description = "Default project"
  type        = string
  default     = ""
}

variable "digitalocean_vms" {
  description = "List of VM configurations."
  type = list(object({
    image  = string
    name   = string
    domain = optional(string)
    region = optional(string)
    size   = string
    tags   = list(string)

    backups    = optional(bool)
    monitoring = optional(bool)
    ipv6       = optional(bool)
    vpc_uuid   = optional(string)

    existing_ssh_keys = optional(bool)
    new_ssh_keys      = optional(map(string))

    resize_disk = optional(bool)

    user_data  = optional(string)
    volume_ids = optional(list(string))
    project    = optional(string)

    record_enable = optional(bool)
    record_type   = optional(string)
    record_domain = optional(string)
    record_name   = optional(string)
    record_ttl    = optional(number)

    ansible_name                 = optional(string)
    ansible_host                 = optional(string)
    ansible_groups               = optional(list(string))
    ansible_user                 = optional(string)
    ansible_ssh_pass             = optional(string)
    ansible_ssh_private_key_file = optional(string)
  }))
  default = []
}

variable "digitalocean_lbs" {
  type = list(object({
    name        = optional(string)
    domain      = optional(string)
    project     = optional(string)
    region      = optional(string)
    droplet_tag = optional(string)
    forwarding_rules = optional(list(object({
      entry_port     = optional(number)
      entry_protocol = optional(string)

      target_port     = optional(number)
      target_protocol = optional(string)

      certificate_name = optional(string)
      tls_passthrough  = optional(bool)
    })))

    healthcheck = optional(object({
      port                     = optional(number)
      protocol                 = optional(string)
      path                     = optional(string)
      check_interval_seconds   = optional(number)
      response_timeout_seconds = optional(number)
      unhealthy_threshold      = optional(number)
      healthy_threshold        = optional(number)
    }))

    record_enable = optional(bool)
    record_domain = optional(string)
    record_name   = optional(string)
    record_type   = optional(string)
    record_ttl    = optional(number)

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
