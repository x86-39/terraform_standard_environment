locals {
  init_commands = [
    "source /opt/vyatta/etc/functions/script-template",
    "configure"
  ]
  record_commands = [for record in var.dns_records : 
      "set system static-host-mapping host-name '${record.name}.${ coalesce(record.domain, var.vyos_default_domain) }' inet '${record.value}'"
      if record.value != ""
  ]
  post_commands = [
    "commit",
    "save",
    "exit"
  ]

  combined_commands = concat(local.init_commands, local.record_commands, local.post_commands)

  script = join("\n", concat(["#!/bin/vbash"], local.combined_commands))
}

output "combined_commands" {
    value = local.combined_commands
}

# Send these commands over SSH
resource "null_resource" "vyos_ssh" {
  count = length(var.dns_records) > 0 ? 1 : 0

  triggers = {
    combined_commands = local.combined_commands
  }

  connection {
    type        = "ssh"
    host        = var.vyos_ssh_ip
    user        = var.vyos_ssh_user
    password    = var.vyos_ssh_password
    port        = var.vyos_ssh_port
    agent       = false
  }
  
  provisioner "file" {
    content     = local.script
    destination = "/tmp/vyos-dns.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vyos-dns.sh",
      "/tmp/vyos-dns.sh"
    ]
  }
}