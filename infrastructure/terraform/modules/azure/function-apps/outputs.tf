output "function_apps_flex" {
  type        = map(any)
  description = "A map containing the full objects of the deployed function apps using flex consumption plan"
  value       = azurerm_function_app_flex_consumption.this
}

output "function_app_identities" {
  value = {
    for k, v in azurerm_function_app_flex_consumption.this : k => {
      principal_id = v.identity[*].principal_id
    }
  }
}