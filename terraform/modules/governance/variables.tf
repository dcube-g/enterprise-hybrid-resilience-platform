variable "resource_group_id" {
  description = "Resource ID of the resource group where governance controls apply."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
