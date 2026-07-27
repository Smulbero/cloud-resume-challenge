output "service_plans" {
  type        = map(any)
  description = "A map containing the full objects of the deployed service plans"
  value       = azurerm_service_plan.this
}
