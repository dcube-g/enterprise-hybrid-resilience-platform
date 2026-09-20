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
  description = "Azure resource group location for global traffic management"
  type        = string
  default     = "centralus"
}

variable "traffic_manager_name" {
  description = "Azure Traffic Manager profile name"
  type        = string
  default     = "core-res-prod-global-tm"
}

variable "traffic_manager_dns_name" {
  description = "Traffic Manager DNS relative name"
  type        = string
  default     = "core-res-prod-global-tm"
}

variable "primary_origin_host" {
  description = "Primary Central US application public IP"
  type        = string
  default     = "48.214.168.255"
}

variable "dr_origin_host" {
  description = "South India DR application public IP"
  type        = string
  default     = "20.44.54.89"
}
