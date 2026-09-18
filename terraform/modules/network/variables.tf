variable "name" {
  description = "Name of the hub virtual network"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the hub virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "Subnet definitions"
  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
