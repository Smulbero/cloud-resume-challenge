variable "role_assignments" {
  type = map(object({
    # Required attributes
    scope        = string
    principal_id = string

    # Optional attributes
    role_definition_id   = optional(number, null)
    role_definition_name = optional(string, null)
    principal_type       = optional(string, null)
    description          = optional(string, "Role assignment description not provided")
  }))
  description = "Map of role assignments to be done"

  validation {
    condition = alltrue([
      for k in var.role_assignments :
      k.role_definition_id != null || k.role_definition_name != null
    ])
    error_message = "Either 'role_definition_id' or 'role_definition_name' must be provided"
  }

  validation {
    condition = alltrue([
      for k in var.role_assignments :
      k.principal_type != null ?
      contains(["User", "Group", "ServicePrincipal"], k.principal_type) : true
    ])
    error_message = "Acceptable values for 'principal_type' attribute: 'User', 'Group', and 'ServicePrincipal'"
  }
}