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

data "azurerm_client_config" "current" {}
data "azurerm_container_registry" "primary" {
  name                = "coreresprodcusacr"
  resource_group_name = "core-res-prod-cus-hub-rg"
}

locals {
  name_prefix = "${var.org}-${var.workload}-${var.environment}-${var.region_code}"
}

resource "azurerm_resource_group" "dr" {
  name     = "${local.name_prefix}-rg"
  location = var.location

  tags = {
    environment = var.environment
    workload    = var.workload
    region      = var.location
    purpose     = "disaster-recovery"
    managed_by  = "terraform"
  }
}

resource "azurerm_virtual_network" "dr" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
  address_space       = var.vnet_address_space

  tags = {
    environment = var.environment
    workload    = var.workload
    region      = var.location
    purpose     = "disaster-recovery"
    managed_by  = "terraform"
  }
}

resource "azurerm_subnet" "management" {
  name                 = "management"
  resource_group_name  = azurerm_resource_group.dr.name
  virtual_network_name = azurerm_virtual_network.dr.name
  address_prefixes     = [var.management_subnet_prefix]
}

resource "azurerm_subnet" "aks_system" {
  name                 = "aks-system"
  resource_group_name  = azurerm_resource_group.dr.name
  virtual_network_name = azurerm_virtual_network.dr.name
  address_prefixes     = [var.aks_system_subnet_prefix]
}

resource "azurerm_subnet" "aks_workload" {
  name                 = "aks-workload"
  resource_group_name  = azurerm_resource_group.dr.name
  virtual_network_name = azurerm_virtual_network.dr.name
  address_prefixes     = [var.aks_workload_subnet_prefix]
}

resource "azurerm_role_assignment" "dr_acr_pull" {
  scope                = data.azurerm_container_registry.primary.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.dr.kubelet_identity[0].object_id
}

resource "azurerm_user_assigned_identity" "app" {
  name                = var.app_identity_name
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name

  tags = {
    environment = var.environment
    workload    = var.workload
    region      = var.location
    purpose     = "disaster-recovery"
    managed_by  = "terraform"
  }
}

resource "azurerm_kubernetes_cluster" "dr" {
  name                = var.aks_name
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
  dns_prefix          = var.aks_dns_prefix

  kubernetes_version = var.aks_kubernetes_version
  sku_tier           = "Free"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name           = "system"
    vm_size        = var.aks_node_vm_size
    node_count     = var.aks_node_count
    vnet_subnet_id = azurerm_subnet.aks_system.id

    type = "VirtualMachineScaleSets"
    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }


  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  monitor_metrics {}

  key_vault_secrets_provider {
    secret_rotation_enabled  = false
    secret_rotation_interval = "2m"
  }

  tags = {
    environment = var.environment
    workload    = var.workload
    region      = var.location
    purpose     = "disaster-recovery"
    managed_by  = "terraform"
  }
}

resource "azurerm_key_vault" "dr" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled = true

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  tags = {
    environment = var.environment
    workload    = var.workload
    region      = var.location
    purpose     = "disaster-recovery"
    managed_by  = "terraform"
  }
}

resource "azurerm_role_assignment" "app_key_vault_secrets_user" {
  scope                = azurerm_key_vault.dr.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

resource "azurerm_key_vault_secret" "resilience_test" {
  name         = var.key_vault_secret_name
  value        = "dr-validation-secret"
  key_vault_id = azurerm_key_vault.dr.id

  depends_on = [
    azurerm_role_assignment.app_key_vault_secrets_user
  ]
}

resource "azurerm_federated_identity_credential" "app" {
  name                      = "core-res-prod-sin-app-federated"
  user_assigned_identity_id = azurerm_user_assigned_identity.app.id

  audience = [
    "api://AzureADTokenExchange"
  ]

  issuer  = azurerm_kubernetes_cluster.dr.oidc_issuer_url
  subject = "system:serviceaccount:resilience-app:resilience-app"
}
