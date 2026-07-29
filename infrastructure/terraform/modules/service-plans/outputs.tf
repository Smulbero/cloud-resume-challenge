output "service_plans" {
  type        = map(any)
  description = "A map containing the full objects of the deployed service plans"
  value       = azurerm_service_plan.this
}

output "ids" {
  type        = map(string)
  description = "A mapping of keys to service plan ids"
  value = {
    for k, v in azurerm_service_plan.this : k => v.id
  }
}