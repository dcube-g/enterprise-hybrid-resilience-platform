resource "azurerm_resource_group" "snapshot" {
  name     = var.snapshot_resource_group_name
  location = var.location

  tags = {
    managed_by = "terraform"
    component  = "aks-backup"
    purpose    = "disaster-recovery"
  }
}

resource "azurerm_data_protection_backup_vault" "aks" {
  name                = var.backup_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location

  datastore_type               = "VaultStore"
  redundancy                   = "GeoRedundant"
  cross_region_restore_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = {
    managed_by = "terraform"
    component  = "aks-backup"
    purpose    = "disaster-recovery"
  }
}

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "aks" {
  name                = var.backup_policy_name
  resource_group_name = var.resource_group_name
  vault_name          = azurerm_data_protection_backup_vault.aks.name

  backup_repeating_time_intervals = [
    "R/2026-01-01T02:00:00+00:00/PT24H"
  ]

  default_retention_rule {
    life_cycle {
      duration        = "P30D"
      data_store_type = "OperationalStore"
    }
  }

  depends_on = [
    azurerm_data_protection_backup_vault.aks
  ]
}

resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "backup" {
  kubernetes_cluster_id = var.aks_id
  name                  = "backuptrustedaccess"

  roles = [
    "Microsoft.DataProtection/backupVaults/backup-operator"
  ]

  source_resource_id = azurerm_data_protection_backup_vault.aks.id

  depends_on = [
    azurerm_data_protection_backup_vault.aks
  ]
}

resource "azurerm_storage_account" "backup" {
  name                     = var.backup_storage_account_name
  resource_group_name      = azurerm_resource_group.snapshot.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true

  tags = {
    managed_by = "terraform"
    component  = "aks-backup"
    purpose    = "disaster-recovery"
  }

  depends_on = [
    azurerm_kubernetes_cluster_trusted_access_role_binding.backup
  ]
}

resource "azurerm_storage_container" "backup" {
  name                  = var.backup_container_name
  storage_account_id    = azurerm_storage_account.backup.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "vault_cluster_reader" {
  scope                = var.aks_id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.aks.identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.aks
  ]
}

resource "azurerm_role_assignment" "vault_snapshot_reader" {
  scope                = azurerm_resource_group.snapshot.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.aks.identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.aks,
    azurerm_resource_group.snapshot
  ]
}

resource "azurerm_role_assignment" "cluster_snapshot_contributor" {
  scope                = azurerm_resource_group.snapshot.id
  role_definition_name = "Contributor"
  principal_id         = var.aks_identity_principal_id

  depends_on = [
    azurerm_resource_group.snapshot
  ]
}
