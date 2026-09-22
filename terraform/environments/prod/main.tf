module "acr" {
  source = "../../modules/acr"

  # name = "${local.name_prefix}${local.region_code}acr"

  name                = "${var.organization}${var.project_name}${var.environment}${local.region_code}acr"
  location            = var.location
  resource_group_name = module.resource_group.name

  sku           = var.acr_sku
  admin_enabled = false

  tags = local.tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  name                = "${local.name_prefix}-${local.region_code}-kv"
  location            = var.location
  resource_group_name = module.resource_group.name
  tenant_id           = var.tenant_id

  tags = local.tags
}

module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = "${local.name_prefix}-${local.region_code}-law"
  location            = var.location
  resource_group_name = module.resource_group.name
  retention_in_days   = var.log_analytics_retention_days

  tags = local.tags
}

locals {
  name_prefix = "${var.organization}-${var.project_name}-${var.environment}"
  region_code = "cus"

  tags = {
    Environment = var.environment
    Project     = "Enterprise Hybrid Resilience Platform"
    ManagedBy   = "Terraform"
    Owner       = var.organization
  }
}

module "resource_group" {
  source = "../../modules/resource-group"

  name     = "${local.name_prefix}-${local.region_code}-hub-rg"
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "../../modules/network"

  name                = "${local.name_prefix}-${local.region_code}-vnet-hub"
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = var.hub_vnet_address_space
  subnets             = var.hub_subnets
  tags                = local.tags
}

module "aks" {
  source = "../../modules/aks"

  name                = "${local.name_prefix}-${local.region_code}-aks-app01"
  location            = var.location
  resource_group_name = module.resource_group.name

  subnet_id = module.network.subnet_ids["aks-system"]

  workload_vm_size    = "Standard_B2pls_v2"
  workload_node_count = 2
  workload_subnet_id  = module.network.subnet_ids["aks-workload"]

  key_vault_id = module.key_vault.id

  dns_prefix = "${local.name_prefix}-${local.region_code}"

  kubernetes_version = var.aks_kubernetes_version

  node_count = var.aks_node_count
  vm_size    = var.aks_vm_size

  acr_id = module.acr.id

  log_analytics_workspace_id = module.log_analytics.id

  tags = local.tags
}

module "backup" {
  source = "../../modules/backup"

  location                  = var.location
  resource_group_name       = module.resource_group.name
  aks_id                    = module.aks.id
  aks_identity_principal_id = module.aks.identity_principal_id

  snapshot_resource_group_name = "${local.name_prefix}-${local.region_code}-backup-snap-rg"
  backup_vault_name            = "${local.name_prefix}-${local.region_code}-backup-vault"
  backup_policy_name           = "${local.name_prefix}-${local.region_code}-aks-backup-policy"

  backup_storage_account_name = "coreresprodcusaksbkp01"
  backup_container_name       = "aksbackup"
}

module "bastion" {
  source = "../../modules/bastion"

  name                = "${local.name_prefix}-${local.region_code}-bastion"
  location            = var.location
  resource_group_name = module.resource_group.name

  subnet_id          = module.network.subnet_ids["AzureBastionSubnet"]
  virtual_network_id = module.network.vnet_id

  tags = local.tags
}


resource "azurerm_user_assigned_identity" "resilience_app" {
  name                = "${local.name_prefix}-${local.region_code}-app-identity"
  location            = var.location
  resource_group_name = module.resource_group.name

  tags = local.tags
}

resource "azurerm_federated_identity_credential" "resilience_app" {
  name                = "${local.name_prefix}-${local.region_code}-app-federated"
  resource_group_name = module.resource_group.name
  parent_id           = azurerm_user_assigned_identity.resilience_app.id

  audience = [
    "api://AzureADTokenExchange"
  ]

  issuer  = module.aks.oidc_issuer_url
  subject = "system:serviceaccount:resilience-app:resilience-app"
}

resource "azurerm_role_assignment" "resilience_app_key_vault_secrets_user" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.resilience_app.principal_id

  depends_on = [
    module.key_vault,
    azurerm_user_assigned_identity.resilience_app
  ]
}

resource "azurerm_role_assignment" "current_user_key_vault_secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [
    module.key_vault
  ]
}

data "azurerm_client_config" "current" {}

