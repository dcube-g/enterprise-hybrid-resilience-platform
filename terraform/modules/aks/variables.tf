variable "name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing AKS"
  type        = string
}

variable "subnet_id" {
  description = "Subnet used by the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version"
  type        = string
  default     = null
}

variable "node_count" {
  description = "Initial system node count"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for AKS system nodes"
  type        = string
  default     = "Standard_B2pls_v2"
}

variable "acr_id" {
  description = "Azure Container Registry resource ID"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "key_vault_id" {
  description = "Resource ID of the Azure Key Vault used by the AKS Secrets Provider"
  type        = string
}

variable "workload_vm_size" {
  description = "VM size for the AKS workload node pool"
  type        = string
  default     = "Standard_B2pls_v2"
}

variable "workload_node_count" {
  description = "Initial node count for the AKS workload node pool"
  type        = number
  default     = 2
}

variable "workload_subnet_id" {
  description = "Subnet ID for the AKS workload node pool"
  type        = string
}
