resource "azurerm_monitor_workspace" "this" {
  name                = var.monitor_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location

  public_network_access_enabled = true

  tags = var.tags
}

resource "azurerm_dashboard_grafana" "this" {
  name                = var.grafana_name
  resource_group_name = var.resource_group_name
  location            = var.location

  grafana_major_version         = 12
  sku                           = "Standard"
  api_key_enabled               = false
  public_network_access_enabled = true
  zone_redundancy_enabled       = false

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.this.id
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "grafana_monitoring_data_reader" {
  scope                = azurerm_monitor_workspace.this.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}
