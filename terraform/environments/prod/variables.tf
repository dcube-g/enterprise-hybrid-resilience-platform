variable "aks_node_count" {
  description = "Initial AKS system node count"
  type        = number
  default     = 2
}

variable "aks_vm_size" {
  description = "AKS system node VM size"
  type        = string
  default     = "Standard_B2pls_v2"
}

variable "aks_kubernetes_version" {
  description = "AKS Kubernetes version. Null uses the Azure default."
  type        = string
  default     = null
}

variable "acr_sku" {
  description = "Azure Container Registry SKU"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID"
  type        = string
  sensitive   = true
}

variable "log_analytics_retention_days" {
  description = "Log Analytics retention period"
  type        = number
  default     = 30
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central US"
}

variable "project_name" {
  description = "Project/workload name"
  type        = string
  default     = "res"
}

variable "organization" {
  description = "Organization identifier"
  type        = string
  default     = "core"
}
variable "hub_vnet_address_space" {
  description = "Address space for the production hub VNet"
  type        = list(string)

  default = [
    "10.100.0.0/16"
  ]
}

variable "hub_subnets" {
  description = "Hub VNet subnet definitions"
  type = map(object({
    address_prefixes = list(string)
  }))

  default = {
    GatewaySubnet = {
      address_prefixes = ["10.100.1.0/27"]
    }

    AzureBastionSubnet = {
      address_prefixes = ["10.100.2.0/26"]
    }

    management = {
      address_prefixes = ["10.100.3.0/24"]
    }

    aks-system = {
      address_prefixes = ["10.100.10.0/23"]
    }

    aks-workload = {
      address_prefixes = ["10.100.12.0/22"]
    }
  }
}
