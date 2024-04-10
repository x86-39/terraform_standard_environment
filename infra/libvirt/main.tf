resource "libvirt_network" "network" {
  name      = var.network_name
  mode      = var.network_mode
  domain    = var.network_name
  addresses = ["${var.network}"]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true

    local_only = false

    dynamic "hosts" {
      for_each = { 
        for vm in var.libvirt_vms : vm.name => vm
        if vm.network_interfaces != null && vm.network_interfaces != [] && vm.network_interfaces[0].ip != null && vm.network_interfaces[0].ip != ""
        }
      # iterator = "hosts"
        
      content {
        // Try to use "${vm.domain}.${vm.name}", then "${var.default_domain}.${vm.name}", then just "${vm.name}"
        hostname = hosts.value.domain != null && hosts.value.domain != "" ? "${hosts.value.name}.${hosts.value.domain}" : (var.default_domain != null && var.default_domain != "" ? "${hosts.value.name}.${var.default_domain}" : hosts.value.name)
        ip   = split("/", hosts.value.network_interfaces[0].ip).0
      }
    }

  }
}
