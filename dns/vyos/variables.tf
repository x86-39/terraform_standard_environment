# Defaults are set for my own environment in tests. You can change them to your own values.
variable "vyos_ssh_ip" {
    description = "VyOS SSH IP"
    type = string
    default = "192.168.21.2"  # This is an IP i use frequently.
}

variable "vyos_ssh_port" {
    description = "VyOS SSH port"
    type = number
    default = 22
}

variable "vyos_ssh_user" {
    description = "VyOS SSH user"
    type = string
    default = "vyos"
}

variable "vyos_ssh_password" {
    description = "VyOS SSH password"
    type = string
    default = "vyos"
}

variable "vyos_default_domain" {
    description = "Default DigitalOcean domain"
    type = string
    default = "terraform.test"
}

variable "dns_records" {
    description = "List of DNS records to create"
    default     = []
    type = list(object({
        domain_id = optional(string)
        domain = optional(string)
        name = string
        value = string
        type = optional(string)
        ttl = optional(number)
    }))
}
