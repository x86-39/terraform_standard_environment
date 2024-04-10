variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "domain" {
  type    = string
  default = ""
}

variable "network" {
  type    = string
  default = "192.168.21.0/24"
}

variable "network_name" {
  type    = string
  default = "terraform"
}

variable "network_mode" {
  type    = string
  default = "nat"
}

variable "libvirt_pool" {
  type    = string
  default = "default"
}
