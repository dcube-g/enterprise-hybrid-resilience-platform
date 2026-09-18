output "id" {
  description = "Log Analytics workspace resource ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "location" {
  description = "Log Analytics workspace location"
  value       = azurerm_log_analytics_workspace.this.location
}
