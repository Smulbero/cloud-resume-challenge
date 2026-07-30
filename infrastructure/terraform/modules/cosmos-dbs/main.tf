resource "random_integer" "this" {
  for_each = var.cosmos_db_accounts

  # Required attributes
  min = var.random_integer.min
  max = var.random_integer.max
}

resource "azurerm_cosmosdb_account" "this" {
  for_each = var.cosmos_db_accounts

  # Required attributes
  name = format(
    "%s-%s",
    each.value.name,
    random_integer.this[each.key].result
  )
  location            = var.resource_groups[each.value.resource_group_key].location
  resource_group_name = var.resource_groups[each.value.resource_group_key].name
  offer_type          = each.value.offer_type

  dynamic "geo_location" {
    for_each = each.value.geo_locations

    content {
      # Required
      failover_priority = each.value.failover_priority
      location          = each.value.location
      # Optional
      zone_redundant = each.value.zone_redundant
    }
  }

  dynamic "consistency_policy" {
    for_each = each.value.consistency_policies

    content {
      # Required
      consistency_level = each.value.consistency_level
      # Optional

      max_interval_in_seconds = each.value.max_interval_in_seconds
      max_staleness_prefix    = each.value.max_staleness_prefix
    }
  }

  # Optional attributes
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}

resource "azurerm_cosmosdb_table" "this" {
  for_each = {
    for k, v in var.cosmos_dbs : k => v.table
    if v.table != null
  }

  # Required attributes
  name                = each.value.name
  resource_group_name = var.resource_groups[each.value.resource_group_key].name
  account_name        = azurerm_cosmosdb_account.this[each.key].name
  # Optional attributes
  throughput = each.value.throughput
}