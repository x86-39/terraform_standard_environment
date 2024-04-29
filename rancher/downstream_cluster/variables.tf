variable "rancher_clusters" {
    description = "List of downstream clusters to create"
    type = list(object({
        name = string
        fleet_namespace = string
        kubernetes_version = string
        enable_network_policy = optional(bool)
        default_cluster_role_for_project_members = optional(string)

        rke_config = optional(object({
            machine_global_config = optional(string)
        }))
    }))
    default = [ 
        {
            name = "downstream"
            fleet_namespace = "fleet-local"
            kubernetes_version = "v1.26.15+rke2r1"

            rke_config = {

                machine_global_config = <<EOF
cni: "cilium"
EOF
            }
        }
    ]
}
