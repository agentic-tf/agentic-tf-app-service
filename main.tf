resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku
  worker_count        = var.worker_count
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.this.id
  virtual_network_subnet_id     = var.integration_subnet_id
  https_only                    = true
  public_network_access_enabled = false

  site_config {
    vnet_route_all_enabled = true
  }

  tags = var.tags
}

# Private endpoint for inbound access
resource "azurerm_private_endpoint" "app" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_linux_web_app.this.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  tags = var.tags
}
