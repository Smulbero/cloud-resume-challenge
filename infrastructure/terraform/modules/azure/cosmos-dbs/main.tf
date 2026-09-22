/*
 * # Module: azure/cosmos-dbs
 *
 * Creates one or more of the following Azure Cosmos DB resources from a map of definitions:
 * - Cosmos DB Account
 * - Cosmos DB Table
 */

resource "azurerm_cosmosdb_account" "this" {
  for_each = var.cosmos_db_accounts

  # Required attributes
  name                = each.value.name
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
  ip_range_filter = var.function_app_ip_addresses_list[each.value.function_app_key]
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

  lifecycle {
    prevent_destroy = true
  }

  # Address checkov issues
  public_network_access_enabled = false # Restrict access and disable public network access.
  access_key_metadata_writes_enabled = false # Prevent metadata writes via account keys. Managed Identites with RBAC are used. Reference ADR #0007.

  # checkov:skip=CKV_AZURE_100:CMKs would require an Azure Key Vault resource which has been decided not to provision. Reference ADR #0007.
  # checkov:skip=CKV_AZURE_140:Check is done against ´local_authentication_disabled´ property which is deprecated. ´local_authentication_enabled´ is used instead. The property targets only SQL API per azurerm provider docs. This project uses the Table API. Reference ADR #0006.
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