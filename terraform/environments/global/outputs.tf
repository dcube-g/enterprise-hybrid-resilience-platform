output "resource_group_name" {
  description = "Global traffic management resource group"
  value       = azurerm_resource_group.global.name
}

output "traffic_manager_profile_name" {
  description = "Azure Traffic Manager profile name"
  value       = azurerm_traffic_manager_profile.global.name
}

output "traffic_manager_fqdn" {
  description = "Azure Traffic Manager DNS hostname"
  value       = azurerm_traffic_manager_profile.global.fqdn
}

output "traffic_manager_profile_id" {
  description = "Azure Traffic Manager profile resource ID"
  value       = azurerm_traffic_manager_profile.global.id
}
