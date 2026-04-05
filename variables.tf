variable "name" {
  type        = string
  description = "Name of the App Service and associated resources."
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "sku" {
  type        = string
  description = "App Service Plan SKU (e.g. B1, S1, P1v3)."
  default     = "B1"
}

variable "worker_count" {
  type        = number
  description = "Number of workers (instances) for the App Service Plan."
  default     = 1
}

variable "integration_subnet_id" {
  type        = string
  description = "Subnet ID for VNet integration (outbound). Must be delegated to Microsoft.Web/serverFarms."
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint (inbound access)."
}

variable "virtual_network_id" {
  type        = string
  description = "VNet ID for private DNS zone links."
}

variable "create_private_dns_zones" {
  type        = bool
  description = "Create private DNS zones for the app private endpoint. Set false if centrally managed."
  default     = true
}

variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Existing private DNS zone IDs keyed by subresource name when create_private_dns_zones = false."
  default     = {}
}

# ── Security variables ────────────────────────────────────────────────

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the App Service (I.AZR.0044)."
  default     = "1.2"

  validation {
    condition     = contains(["1.2", "1.3"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be \"1.2\" or \"1.3\"."
  }
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for diagnostic logs (I.AZR.0013). Empty string to skip."
  default     = ""
}

# ── Tags ──────────────────────────────────────────────────────────────

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}
