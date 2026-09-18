variable "name" {
  description = "Name of the Azure Bastion host"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing Azure Bastion"
  type        = string
}

variable "subnet_id" {
  description = "AzureBastionSubnet resource ID"
  type        = string
}

variable "sku" {
  description = "Azure Bastion SKU"
  type        = string
  default     = "Developer"

  validation {
    condition     = contains(["Developer", "Basic", "Standard", "Premium"], var.sku)
    error_message = "Bastion SKU must be Developer, Basic, Standard, or Premium."
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "virtual_network_id" {
  description = "ID of the virtual network for Azure Bastion"
  type        = string
}
