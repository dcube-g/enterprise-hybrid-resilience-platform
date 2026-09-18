output "name_prefix" {
  description = "Common resource name prefix"
  value       = local.name_prefix
}

output "region_code" {
  description = "Short Azure region code"
  value       = local.region_code
}

output "resource_group_id" {
  description = "Hub resource group resource ID"
  value       = module.resource_group.id
}

output "resource_group_name" {
  description = "Name of the hub resource group"
  value       = module.resource_group.name
}

output "hub_vnet_id" {
  description = "ID of the hub VNet"
  value       = module.network.vnet_id
}

output "hub_vnet_name" {
  description = "Name of the hub VNet"
  value       = module.network.vnet_name
}

output "hub_subnet_ids" {
  description = "Map of hub subnet names to resource IDs"
  value       = module.network.subnet_ids
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  value       = module.log_analytics.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = module.log_analytics.name
}

output "log_analytics_workspace_guid" {
  description = "Log Analytics workspace GUID"
  value       = module.log_analytics.workspace_id
}

output "key_vault_id" {
  description = "Key Vault resource ID"
  value       = module.key_vault.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.uri
}

output "acr_id" {
  description = "Azure Container Registry resource ID"
  value       = module.acr.id
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = module.acr.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = module.acr.login_server
}

output "aks_id" {
  description = "AKS cluster resource ID"
  value       = module.aks.id
}

output "aks_name" {
  description = "AKS cluster name"
  value       = module.aks.name
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL"
  value       = module.aks.oidc_issuer_url
}

output "aks_kubelet_client_id" {
  description = "AKS kubelet managed identity client ID"
  value       = module.aks.kubelet_identity_client_id
}

output "aks_kubelet_object_id" {
  description = "AKS kubelet managed identity object ID"
  value       = module.aks.kubelet_identity_object_id
}

output "aks_identity_principal_id" {
  description = "AKS control plane managed identity principal ID"
  value       = module.aks.identity_principal_id
}

output "bastion_id" {
  description = "Azure Bastion resource ID"
  value       = module.bastion.bastion_id
}

output "bastion_name" {
  description = "Azure Bastion host name"
  value       = "${local.name_prefix}-${local.region_code}-bastion"
}

output "bastion_public_ip_id" {
  description = "Azure Bastion public IP resource ID"
  value       = module.bastion.public_ip_id
}

output "bastion_public_ip_address" {
  description = "Azure Bastion public IP address"
  value       = module.bastion.public_ip_address
}

output "monitor_workspace_id" {
  value = module.monitoring.monitor_workspace_id
}

output "monitor_workspace_query_endpoint" {
  value = module.monitoring.monitor_workspace_query_endpoint
}

output "grafana_id" {
  value = module.monitoring.grafana_id
}

output "grafana_endpoint" {
  value = module.monitoring.grafana_endpoint
}
