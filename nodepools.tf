locals {
  node_pools = {
    user = {
      name                = "user"
      vm_size             = var.agents_size
      enable_auto_scaling = true
      node_count          = null
      min_count           = 1
      max_count           = 3
      vnet_subnet_id      = lookup(module.network.vnet_subnets_name_id, "aks")
    },
    ingress = {
      name                = "ingress"
      vm_size             = var.agents_size
      enable_auto_scaling = false
      node_count          = 2
      vnet_subnet_id      = lookup(module.network.vnet_subnets_name_id, "aks")
      node_taints         = ["node-role.kubernetes.io/ingress=true:NoSchedule"]
    },
    spot = {
      name                = "spot"
      vm_size             = var.agents_size
      enable_auto_scaling = true
      node_count          = null
      min_count           = 1
      max_count           = 10
      vnet_subnet_id      = lookup(module.network.vnet_subnets_name_id, "aks")
      eviction_policy     = "Delete"
      spot_max_price      = 0.1
      priority            = "Spot"
      node_taints         = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
      node_labels         = { "kubernetes.azure.com/scalesetpriority" = "spot" }
      zones               = ["1", "2", "3"]

    },
  }
}