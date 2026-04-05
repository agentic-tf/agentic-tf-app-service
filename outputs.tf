output "id" {
  description = "Resource ID of the Linux Web App."
  value       = azurerm_linux_web_app.this.id
}

output "name" {
  description = "Name of the Linux Web App."
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "Default hostname of the Linux Web App."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity."
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}
