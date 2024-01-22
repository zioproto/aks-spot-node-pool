module "aks" {
  source                            = "github.com/Azure/terraform-azurerm-aks.git?ref=be5ef5c3948b6305a0913d1f00b8eadcd01e7314"
  resource_group_name               = azurerm_resource_group.this.name
  location                          = var.region
  kubernetes_version                = var.kubernetes_version
  orchestrator_version              = var.kubernetes_version
  role_based_access_control_enabled = true
  rbac_aad                          = false
  prefix                            = "spotty"
  network_plugin                    = "azure"
  vnet_subnet_id                    = lookup(module.network.vnet_subnets_name_id, "aks")
  os_disk_size_gb                   = 50
  sku_tier                          = "Standard"
  private_cluster_enabled           = false
  enable_auto_scaling               = true
  enable_host_encryption            = false
  log_analytics_workspace_enabled   = true
  agents_min_count                  = 1
  agents_max_count                  = 5
  agents_count                      = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                   = 36
  agents_pool_name                  = "system"
  agents_availability_zones         = ["1", "2", "3"]
  agents_type                       = "VirtualMachineScaleSets"
  agents_size                       = var.agents_size
  monitor_metrics                   = {}
  azure_policy_enabled              = true
  microsoft_defender_enabled        = true

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  network_policy             = "azure"
  net_profile_dns_service_ip = "10.0.0.10"
  net_profile_service_cidr   = "10.0.0.0/16"

  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled            = true
  secret_rotation_interval           = "3m"

  node_pools = local.node_pools

  storage_profile_enabled             = true
  storage_profile_blob_driver_enabled = true

  network_contributor_role_assigned_subnet_ids = { "aks" = lookup(module.network.vnet_subnets_name_id, "aks") }

  depends_on = [module.network]
}
