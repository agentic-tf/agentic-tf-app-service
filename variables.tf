variable "name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
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
variable "tags" {
  type    = map(string)
  default = {}
}
