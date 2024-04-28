resource "null_resource" "download_urls" {
  provisioner "local-exec" {
    command = <<EOF
%{ for file in var.download_urls }
if [ ! -f "${file.dest}" ]; then
  curl -L -o "${file.dest}.tmp" "${file.url}"
  mv "${file.dest}.tmp" "${file.dest}"
fi
%{ endfor }
EOF

  }

  provisioner "local-exec" {
    when    = destroy
    command = "$YOUR_CURL_DELETE_COMMAND"
  }
}

module "libvirt_vm" {
  source     = "diademiemi/vm/libvirt"
  version    = "6.0.1"
  depends_on = [
    libvirt_network.network,
    null_resource.download_urls
  ]

  for_each = { for vm in var.libvirt_vms : vm.name => vm }

  name = each.value.name
  domain   = try(coalesce(each.value.domain, var.default_domain), null)

  vcpu   = try(each.value.vcpu, null)
  memory = try(each.value.memory, null)

  autostart = try(each.value.autostart, null)

  cloudinit_image = try(each.value.cloudinit_image, null)

  disk_size         = try(each.value.disk_size, null)
  libvirt_pool      = try(each.value.libvirt_pool, null)
  disk_passthroughs = try(each.value.disk_passthroughs, null)
  iso_urls          = try(each.value.iso_urls, null)
  iso_paths         = try(each.value.iso_paths, null)

  ssh_keys              = try(each.value.ssh_keys, null)
  password_auth         = try(each.value.password_auth, null)
  root_password         = try(each.value.root_password, null)
  allow_root_ssh_pwauth = try(each.value.allow_root_ssh_pwauth, null)
  disable_root          = try(each.value.disable_root, null)

  # libvirt_external_interface = each.value.libvirt_external_interface
  # mac = each.value.mac

  network_interfaces = try(each.value.network_interfaces, null)

  spice_enabled = try(each.value.spice_enabled, null)

  cloudinit_use_user_data = try(each.value.cloudinit_use_user_data, null)
  cloudinit_use_network_data = try(each.value.cloudinit_use_network_data, null)
  cloudinit_custom_user_data = try(each.value.cloudinit_custom_user_data, null)
  cloudinit_custom_network_data = try(each.value.cloudinit_custom_network_data, null)

  ansible_name   = try(each.value.ansible_name, null)
  ansible_host   = try(each.value.ansible_host, null)
  ansible_groups = try(each.value.ansible_groups, null)
  ansible_user   = try(each.value.ansible_user, null)
  ansible_ssh_pass = try(each.value.ansible_ssh_pass, null)
  ansible_ssh_private_key_file = try(each.value.ansible_ssh_private_key_file, null)

}

# Create list like:
# - name: "vm"
#   value: $vm.value.primary_ipv4_address
#   type: "A"
# Ignore the domain, we get it in the DNS code
output "dns_records" {
  depends_on = [module.libvirt_vm]
  value = [for vm_name, vm in module.libvirt_vm : {
    name: length(split(".", vm.name)) > 2 ? join(".", slice(split(".", vm.name), 0, length(split(".", vm.name)) - 2)) : split(".", vm.name)[0]
    value: split("/", vm.primary_ipv4_address).0,  # Replace with the actual attribute for the primary IPv4 address
    type: "A"
  }]
}

output "default_domain" {
  value = var.default_domain
}
