/*
 * # Resource Group Module
 *
 * This is a test terraform documentation
 */
 
resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups
  
  # Required attributes
  name     = format(
    "%s-%s-%s",
    var.resource_type_prefix,
    each.key,
    each.value.location
  )
  location = each.value.location

  # Optional attributes
  tags = merge(
    {deployedDate = formatdate("DD-MM-YYYY", timestamp())},
    var.general_tags,
    each.value.tags
  )
}