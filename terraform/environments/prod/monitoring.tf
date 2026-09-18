module "monitoring" {
  source = "../../modules/monitoring"

  monitor_workspace_name = "${local.name_prefix}-${local.region_code}-amw"
  grafana_name           = "${local.name_prefix}-${local.region_code}-gf"

  location            = var.location
  resource_group_name = module.resource_group.name

  tags = local.tags
}

resource "azurerm_role_assignment" "current_user_grafana_editor" {
  scope                = module.monitoring.grafana_id
  role_definition_name = "Grafana Editor"
  principal_id         = data.azurerm_client_config.current.object_id
}
