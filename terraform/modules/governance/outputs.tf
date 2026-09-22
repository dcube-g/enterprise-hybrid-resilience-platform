output "resource_group_lock_id" {
  description = "ID of the resource group management lock."
  value       = azurerm_management_lock.resource_group.id
}
