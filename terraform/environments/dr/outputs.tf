output "resource_group_name" {
  description = "DR resource group name"
  value       = azurerm_resource_group.dr.name
}

output "location" {
  description = "DR region"
  value       = azurerm_resource_group.dr.location
}

output "name_prefix" {
  description = "DR resource naming prefix"
  value       = local.name_prefix
}

output "vnet_name" {
  description = "DR VNet name"
  value       = azurerm_virtual_network.dr.name
}

output "vnet_id" {
  description = "DR VNet resource ID"
  value       = azurerm_virtual_network.dr.id
}

output "aks_system_subnet_id" {
  description = "DR AKS system subnet ID"
  value       = azurerm_subnet.aks_system.id
}

output "aks_workload_subnet_id" {
  description = "DR AKS workload subnet ID"
  value       = azurerm_subnet.aks_workload.id
}

output "aks_name" {
  description = "DR AKS cluster name"
  value       = azurerm_kubernetes_cluster.dr.name
}

output "aks_id" {
  description = "DR AKS cluster resource ID"
  value       = azurerm_kubernetes_cluster.dr.id
}

output "aks_kubernetes_version" {
  description = "DR AKS Kubernetes version"
  value       = azurerm_kubernetes_cluster.dr.kubernetes_version
}

output "app_identity_client_id" {
  description = "DR application managed identity client ID"
  value       = azurerm_user_assigned_identity.app.client_id
}

output "app_identity_principal_id" {
  description = "DR application managed identity principal ID"
  value       = azurerm_user_assigned_identity.app.principal_id
}

output "key_vault_name" {
  description = "DR Key Vault name"
  value       = azurerm_key_vault.dr.name
}

output "key_vault_id" {
  description = "DR Key Vault resource ID"
  value       = azurerm_key_vault.dr.id
}

output "aks_oidc_issuer_url" {
  description = "DR AKS OIDC issuer URL"
  value       = azurerm_kubernetes_cluster.dr.oidc_issuer_url
}
