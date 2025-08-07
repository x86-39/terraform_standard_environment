module "do_vm" {
  source  = "x86-39/vm/digitalocean"
  version = "1.1.1"

  for_each = { for vm in var.digitalocean_vms : vm.name => vm }

  project    = try(coalesce(each.value.project, var.default_project), null)

  name   = each.value.name
  image  = try(each.value.image, null)
  domain = try(coalesce(each.value.domain, var.default_domain), null)
  region = try(coalesce(each.value.region, var.default_region), null)
  size   = try(each.value.size, null)
  tags   = try(each.value.tags, [])

  backups    = try(each.value.backups, null)
  monitoring = try(each.value.monitoring, null)
  ipv6       = try(each.value.ipv6, null)
  vpc_uuid   = try(each.value.vpc_uuid, null)

  existing_ssh_keys = try(each.value.existing_ssh_keys, null)
  new_ssh_keys      = try(each.value.new_ssh_keys, null)

  resize_disk = try(each.value.resize_disk, null)

  user_data  = try(each.value.user_data, null)
  volume_ids = try(each.value.volume_ids, null)

  ansible_name                 = try(each.value.ansible_name, null)
  ansible_host                 = try(each.value.ansible_host, null)
  ansible_groups               = try(each.value.ansible_groups, null)
  ansible_user                 = try(each.value.ansible_user, null)
  ansible_ssh_pass             = try(each.value.ansible_ssh_pass, null)
  ansible_ssh_private_key_file = try(each.value.ansible_ssh_private_key_file, null)
}

module "do_lb" {
  source  = "x86-39/loadbalancer/digitalocean"
  version = "1.2.1"

  for_each = { for i, v in var.digitalocean_lbs : i => v }

  name             = each.value.name
  domain          = try(coalesce(each.value.domain, var.default_domain), null)
  project          = try(coalesce(each.value.project, var.default_project), null)
  region           = try(coalesce(each.value.region, var.default_region), null)
  droplet_tag      = each.value.droplet_tag

  forwarding_rules = try(each.value.forwarding_rules, null)

  healthcheck = try(each.value.healthcheck, null)

}

# Create list like:
# - name: "vm"
#   value: $vm.value.primary_ipv4_address
#   type: "A"
# Ignore the domain, we get it in the DNS code
locals {
  dns_records_vms = [for vm_hostname, vm in module.do_vm : {
    name: length(split(".", vm.name)) > 2 ? join(".", slice(split(".", vm.name), 0, length(split(".", vm.name)) - 2)) : split(".", vm.name)[0]
    value: vm.ipv4_address,  # Replace with the actual attribute for the primary IPv4 address
    type: "A"
  }]

  dns_records_lbs = [for lb_name, lb in module.do_lb : {
    name: length(split(".", lb.name)) > 2 ? join(".", slice(split(".", lb.name), 0, length(split(".", lb.name)) - 2)) : split(".", lb.name)[0]
    value: lb.ipv4_address,  # Replace with the actual attribute for the primary IPv4 address
    type: "A"
  }]
}

output "dns_records" {
  value = concat(local.dns_records_vms, local.dns_records_lbs)
}

output "default_domain" {
  value = var.default_domain
}
