# Configure the Rancher2 provider to bootstrap and admin
# Provider config for bootstrap

# Create a new rancher2_bootstrap using bootstrap provider config

resource "rancher2_cluster_v2" "clusters" {
  for_each = { for cluster in var.rancher_clusters : cluster.name => cluster }

  name = each.value.name

  labels = {
    "identifier/name": each.value.name
  }

  fleet_namespace = each.value.fleet_namespace

  kubernetes_version = each.value.kubernetes_version

  enable_network_policy = try(each.value.enable_network_policy, false)
  default_cluster_role_for_project_members = try(each.value.default_cluster_role_for_project_members, "user")

  dynamic "rke_config" {
    for_each = each.value.rke_config == null ? toset([]) : toset([1])
    
    content {
      machine_global_config = each.value.rke_config.machine_global_config
    }
  }
}
