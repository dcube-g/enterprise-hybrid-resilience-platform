resource "azurerm_public_ip" "this" {
  count = var.sku == "Developer" ? 0 : 1

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = var.sku

  virtual_network_id = var.virtual_network_id

  dynamic "ip_configuration" {
    for_each = var.sku == "Developer" ? [] : [1]

    content {
      name                 = "bastion-ip-config"
      subnet_id            = var.subnet_id
      public_ip_address_id = azurerm_public_ip.this[0].id
    }
  }

  tags = var.tags
}
