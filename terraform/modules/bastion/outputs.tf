output "bastion_id" {
  description = "Resource ID of the Azure Bastion host"
  value       = azurerm_bastion_host.this.id
}

output "public_ip_id" {
  description = "Resource ID of the Bastion public IP"
  value       = var.sku == "Developer" ? null : azurerm_public_ip.this[0].id
}

output "public_ip_address" {
  description = "Public IP address of the Bastion host"
  value       = var.sku == "Developer" ? null : azurerm_public_ip.this[0].ip_address
}
