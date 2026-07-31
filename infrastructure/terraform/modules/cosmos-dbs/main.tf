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
      failover_priority = geo_location.value.failover_priority
      location          = geo_location.value.location
      # Optional
      zone_redundant = geo_location.value.zone_redundant
    }
  }

  consistency_policy {
    # Required
    consistency_level = each.value.consistency_policy.consistency_level
    # Optional
    max_interval_in_seconds = each.value.consistency_policy.max_interval_in_seconds
    max_staleness_prefix    = each.value.consistency_policy.max_staleness_prefix

  }

  # Optional attributes
  dynamic "capabilities" {
    for_each = each.value.capabilities

    content {
      name = capabilities.value.name
    }
  }
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}

resource "azurerm_cosmosdb_table" "this" {
  for_each = var.cosmos_db_tables

  # Required attributes
  name                = each.value.name
  resource_group_name = var.resource_groups[each.value.resource_group_key].name
  account_name        = azurerm_cosmosdb_account.this[each.value.cosmosdb_account_key].name
  # Optional attributes
  throughput = each.value.throughput
}