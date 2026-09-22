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

variable "network_security_groups" {
  description = "Optional network security groups and their rules."

  type = map(object({
    subnet_names = list(string)

    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
      description                = string
    }))
  }))

  default = {}
}
