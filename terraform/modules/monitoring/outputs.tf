output "monitor_workspace_id" {
  value = azurerm_monitor_workspace.this.id
}

output "monitor_workspace_query_endpoint" {
  value = azurerm_monitor_workspace.this.query_endpoint
}

output "grafana_id" {
  value = azurerm_dashboard_grafana.this.id
}

output "grafana_endpoint" {
  value = azurerm_dashboard_grafana.this.endpoint
}

output "grafana_principal_id" {
  value = azurerm_dashboard_grafana.this.identity[0].principal_id
}
