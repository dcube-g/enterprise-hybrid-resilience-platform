variable "location" {
  description = "Azure region for the backup infrastructure."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the primary AKS environment."
  type        = string
}

variable "aks_id" {
  description = "Resource ID of the primary AKS cluster."
  type        = string
}

variable "aks_identity_principal_id" {
  description = "Principal ID of the primary AKS system-assigned identity."
  type        = string
}

variable "snapshot_resource_group_name" {
  description = "Resource group used for AKS backup snapshots."
  type        = string
}

variable "backup_vault_name" {
  description = "Name of the AKS Backup vault."
  type        = string
}

variable "backup_policy_name" {
  description = "Name of the AKS backup policy."
  type        = string
}

variable "backup_storage_account_name" {
  description = "Storage account used by the AKS Backup infrastructure."
  type        = string
}

variable "backup_container_name" {
  description = "Blob container used by the AKS Backup infrastructure."
  type        = string
  default     = "aksbackup"
}
