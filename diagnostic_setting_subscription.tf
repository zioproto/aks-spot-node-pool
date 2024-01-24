data "azurerm_subscription" "current" {
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  depends_on = [module.aks.azurerm_log_analytics_workspace_id]

  name                       = "subscriptionds"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = module.aks.azurerm_log_analytics_workspace_id


  log {
    category = "Administrative"
    enabled  = true
  }

  log {
    category = "Security"
    enabled  = true
  }

  log {
    category = "ServiceHealth"
    enabled  = true
  }

  log {
    category = "Alert"
    enabled  = true
  }

  log {
    category = "Recommendation"
    enabled  = true
  }

  log {
    category = "Policy"
    enabled  = true
  }

  log {
    category = "Autoscale"
    enabled  = true
  }

  log {
    category = "ResourceHealth"
    enabled  = true
  }
}
