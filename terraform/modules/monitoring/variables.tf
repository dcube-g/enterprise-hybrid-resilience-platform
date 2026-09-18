variable "monitor_workspace_name" {
  description = "Azure Monitor workspace name"
  type        = string
}

variable "grafana_name" {
  description = "Azure Managed Grafana workspace name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing monitoring resources"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
}
