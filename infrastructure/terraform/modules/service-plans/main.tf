resource "azurerm_service_plan" "this" {
  for_each = var.service_plans

  # Required attributes
  name = format(
    "%s-%s",
    var.resource_name_prefix,
    each.value.name
  )
  resource_group_name      = var.resource_groups[each.value.resource_group_key].name
  location                 = var.resource_groups[each.value.resource_group_key].location
  os_type = each.value.os_type
  sku_name = each.value.sku_names

  # Optional attributes
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}