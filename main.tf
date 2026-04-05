locals {
  private_dns_zone_ids = var.create_private_dns_zones ? {
    sites = azurerm_private_dns_zone.app[0].id
  } : var.private_dns_zone_ids
}

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

    # I.AZR.0044 — minimum TLS 1.2
    minimum_tls_version = var.minimum_tls_version

    # I.AZR.0045 — FTP disabled
    ftps_state = "Disabled"

    # Best practice — HTTP/2 for improved performance
    http2_enabled = true
  }

  # I.AZR.0019 — Managed Identity
  identity {
    type = "SystemAssigned"
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

  dynamic "private_dns_zone_group" {
    for_each = contains(keys(local.private_dns_zone_ids), "sites") ? [1] : []
    content {
      name                 = "app-dns-group"
      private_dns_zone_ids = [local.private_dns_zone_ids["sites"]]
    }
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "app" {
  count               = var.create_private_dns_zones ? 1 : 0
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "app" {
  count                 = var.create_private_dns_zones ? 1 : 0
  name                  = "${var.name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.app[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}

# ── Diagnostic Settings (I.AZR.0013) ─────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "app" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  metric {
    category = "AllMetrics"
  }
}
