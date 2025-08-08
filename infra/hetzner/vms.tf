module "hetzner_vm" {
  source     = "x86-39/vm/hetzner"
  version    = "2.1.1"

  depends_on = [
    hcloud_network.private_network,
    hcloud_network_subnet.private_subnet
  ]

  for_each = { for vm in var.hetzner_vms : vm.name => vm }

  name = each.value.name
  domain = try(coalesce(each.value.domain, var.default_domain), null)
  type = try(each.value.type, null)
  image       = try(each.value.image, null)
  datacenter    = try(coalesce(each.value.datacenter, var.default_datacenter), null)

  enable_existing_ssh_keys = try(each.value.enable_existing_ssh_keys, false)
  new_ssh_keys = try(each.value.new_ssh_keys, {})

  labels = try(each.value.labels, {})

  ipv6_enabled = try(each.value.ipv6_enabled, false)

  network_id         = try(each.value.network_id, hcloud_network.private_network.id)
  network_ip         = try(each.value.network_ip, null)
  network_ip_aliases = try(each.value.network_ip_aliases, null)

  ansible_name   = try(each.value.ansible_name, null)
  ansible_host   = try(each.value.ansible_host, null)
  ansible_user   = try(each.value.ansible_user, null)
  ansible_ssh_pass = try(each.value.ansible_ssh_pass, null)
  ansible_groups = try(each.value.ansible_groups, null)
}

module "hetzner_lb" {
  source     = "x86-39/loadbalancer/hetzner"
  version    = "1.2.1"

  depends_on = [
    module.hetzner_vm
  ]

  for_each = { for lb in var.hetzner_lbs : lb.name => lb }

  name = each.value.name
  domain = try(coalesce(each.value.domain, var.default_domain), null)
  location = try(each.value.location, null)
  network_zone = try(coalesce(each.value.network_zone, var.default_network_zone), null)
  targets = each.value.targets

  services = try(each.value.services, [])
}

# Create list like:
# - name: "vm"
#   value: $vm.value.primary_ipv4_address
#   type: "A"
# Ignore the domain, we get it in the DNS code
locals {
  dns_records_vms = [for vm_name, vm in module.hetzner_vm : {
    name: length(split(".", vm.name)) > 2 ? join(".", slice(split(".", vm.name), 0, length(split(".", vm.name)) - 2)) : split(".", vm.name)[0]
    value: vm.primary_ipv4_address,  # Replace with the actual attribute for the primary IPv4 address
    type: "A"
  }]

  dns_records_lbs = [for lb_name, lb in module.hetzner_lb : {
    name: length(split(".", lb.name)) > 2 ? join(".", slice(split(".", lb.name), 0, length(split(".", lb.name)) - 2)) : split(".", lb.name)[0]
    value: lb.ipv4_address,  # Replace with the actual attribute for the primary IPv4 address
    type: "A"
  }]
}

output "dns_records" {
  value = concat(local.dns_records_vms, local.dns_records_lbs, var.additional_dns_records)
}

output "default_domain" {
  value = var.default_domain
}
