resource "azurerm_function_app_flex_consumption" "this" {
  for_each = var.function_apps

  # Required attributes
  name = format(
    "%s-%s",
    var.resource_name_prefix,
    each.value.name
  )
  resource_group_name         = var.resource_groups[each.value.resource_group_key].name
  location                    = var.resource_groups[each.value.resource_group_key].location
  service_plan_id             = var.service_plans[each.value.service_plan_key].id
  storage_container_type      = each.value.storage_container_type
  storage_container_endpoint  = "${var.storage_accounts[each.value.storage_account_key].primary_blob_endpoint}${var.storage_containers[each.value.storage_account_key].name}"
  storage_authentication_type = each.value.storage_authentication_type
  runtime_name                = each.value.runtime_name
  runtime_version             = each.value.runtime_version
  site_config {}

  # Optional attributes
  app_settings = each.value.app_settings
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}