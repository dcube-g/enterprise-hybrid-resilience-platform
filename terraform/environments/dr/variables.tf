variable "org" {
  description = "Organization identifier"
  type        = string
  default     = "core"
}

variable "workload" {
  description = "Workload identifier"
  type        = string
  default     = "res"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure DR region"
  type        = string
  default     = "southindia"
}

variable "region_code" {
  description = "Short Azure region code"
  type        = string
  default     = "sin"
}

variable "vnet_address_space" {
  description = "DR VNet address space"
  type        = list(string)
  default     = ["10.200.0.0/16"]
}

variable "management_subnet_prefix" {
  description = "DR management subnet"
  type        = string
  default     = "10.200.3.0/24"
}

variable "aks_system_subnet_prefix" {
  description = "DR AKS system subnet"
  type        = string
  default     = "10.200.10.0/23"
}

variable "aks_workload_subnet_prefix" {
  description = "DR AKS workload subnet"
  type        = string
  default     = "10.200.12.0/22"
}

variable "aks_name" {
  description = "DR AKS cluster name"
  type        = string
  default     = "core-res-prod-sin-aks-dr01"
}

variable "aks_dns_prefix" {
  description = "DR AKS DNS prefix"
  type        = string
  default     = "core-res-prod-sin-aks"
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for DR AKS"
  type        = string
  default     = "1.35"
}

variable "aks_node_vm_size" {
  description = "DR AKS node VM size"
  type        = string
  default     = "Standard_B2als_v2"
}

variable "aks_node_count" {
  description = "Initial DR AKS node count"
  type        = number
  default     = 1
}

variable "app_identity_name" {
  description = "DR application managed identity name"
  type        = string
  default     = "core-res-prod-sin-app-identity"
}

variable "key_vault_name" {
  description = "DR Key Vault name"
  type        = string
  default     = "core-res-prod-sin-kv"
}

variable "key_vault_secret_name" {
  description = "DR application test secret name"
  type        = string
  default     = "resilience-test-secret"
}
