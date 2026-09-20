terraform {
  required_version = ">= 1.16.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  name_prefix = "${var.org}-${var.workload}-${var.environment}-global"
}

resource "azurerm_resource_group" "global" {
  name     = "${local.name_prefix}-rg"
  location = var.location

  tags = {
    environment = var.environment
    workload    = var.workload
    purpose     = "global-traffic-management"
    managed_by  = "terraform"
  }
}

resource "azurerm_traffic_manager_profile" "global" {
  name                   = var.traffic_manager_name
  resource_group_name    = azurerm_resource_group.global.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = var.traffic_manager_dns_name
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/health"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }

  tags = {
    environment = var.environment
    workload    = var.workload
    purpose     = "global-traffic-management"
    managed_by  = "terraform"
  }
}

resource "azurerm_traffic_manager_external_endpoint" "primary" {
  name       = "${local.name_prefix}-primary"
  profile_id = azurerm_traffic_manager_profile.global.id

  target   = var.primary_origin_host
  priority = 1
}

resource "azurerm_traffic_manager_external_endpoint" "dr" {
  name       = "${local.name_prefix}-dr"
  profile_id = azurerm_traffic_manager_profile.global.id

  target   = var.dr_origin_host
  priority = 2
}
