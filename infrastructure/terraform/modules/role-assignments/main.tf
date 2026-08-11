resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  # Required attributes
  scope        = each.value.scope
  principal_id = each.value.principal_id

  # Optional attributes
  role_definition_id   = each.value.role_definition_id
  role_definition_name = each.value.role_definition_name
  principal_type       = each.value.principal_type
  description          = each.value.description
}