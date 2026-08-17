output "role_assignments" {
  type        = map(any)
  description = "A map containing the full objects of set role assignments"
  value       = azurerm_role_assignment.this
}