resource "azurerm_management_lock" "resource_group" {
  name       = "governance-lock-${var.environment}"
  scope      = var.resource_group_id
  lock_level = "CanNotDelete"

  notes = "Protects the ${var.environment} resource group from accidental deletion."
}
