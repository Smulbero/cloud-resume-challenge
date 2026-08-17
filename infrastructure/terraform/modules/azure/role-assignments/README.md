<!-- BEGIN_TF_DOCS -->
# Module: azure/role-assignments

Creates one or more Azure Role Assignments from a map of definitions.

## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Map of role assignments to be done | <pre>map(object({<br/>    # Required attributes<br/>    scope        = string<br/>    principal_id = string<br/><br/>    # Optional attributes<br/>    role_definition_id   = optional(number, null)<br/>    role_definition_name = optional(string, null)<br/>    principal_type       = optional(string, null)<br/>    description          = optional(string, "Role assignment description not provided")<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_role_assignments"></a> [role\_assignments](#output\_role\_assignments) | A map containing the full objects of set role assignments |
<!-- END_TF_DOCS -->