output "backup_vault_id" {
  description = "Resource ID of the AKS Backup vault."
  value       = azurerm_data_protection_backup_vault.aks.id
}

output "backup_vault_name" {
  description = "Name of the AKS Backup vault."
  value       = azurerm_data_protection_backup_vault.aks.name
}

output "backup_policy_id" {
  description = "Resource ID of the AKS backup policy."
  value       = azurerm_data_protection_backup_policy_kubernetes_cluster.aks.id

}

output "backup_storage_account_name" {
  description = "Name of the storage account used by the AKS Backup extension."
  value       = azurerm_storage_account.backup.name
}
