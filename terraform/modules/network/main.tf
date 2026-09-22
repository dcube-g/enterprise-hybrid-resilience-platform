resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "this" {
  for_each = var.network_security_groups

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = {
    for association in flatten([
      for nsg_name, nsg in var.network_security_groups : [
        for subnet_name in nsg.subnet_names : {
          key         = "${nsg_name}-${subnet_name}"
          nsg_name    = nsg_name
          subnet_name = subnet_name
        }
      ]
    ]) : association.key => association
  }

  subnet_id = azurerm_subnet.this[each.value.subnet_name].id

  network_security_group_id = azurerm_network_security_group.this[
    each.value.nsg_name
  ].id
}
