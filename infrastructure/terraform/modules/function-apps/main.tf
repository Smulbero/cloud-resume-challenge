resource "azurerm_linux_function_app" "this" {
  for_each = var.function_apps

  # Required attributes
  name = format(
    "%s-%s",
    var.resource_name_prefix,
    each.value.name
  )
  resource_group_name = var.resource_groups[each.value.resource_group_key].name
  location = var.resource_groups[each.value.resource_group_key].location
  service_plan_id = var.service_plans[each.value.service_plan_key].id
  site_config {
    application_stack {
      python_version = each.value.site_config.application_stack.python_version
    }
  }

  # Optional attributes
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}