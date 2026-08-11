/*
 * # Resource Group Module
 *
 * This is a test terraform documentation
 */

resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups

  # Required attributes
  name = format(
    "%s-%s",
    var.resource_name_prefix,
    each.key
  )
  location = each.value.location

  # Optional attributes
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}