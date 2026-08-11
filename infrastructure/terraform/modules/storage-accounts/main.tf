resource "random_integer" "this" {
  for_each = var.storage_accounts

  # Required attributes
  min = var.random_integer.min
  max = var.random_integer.max

  keepers = {
    ran_int = each.key
  }
}

resource "azurerm_storage_account" "this" {
  for_each = var.storage_accounts

  # Required attributes
  name = format(
    "%s%s",
    each.value.name,
    random_integer.this[each.key].result
  )
  resource_group_name      = var.resource_groups[each.value.resource_group_key].name
  location                 = var.resource_groups[each.value.resource_group_key].location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type

  # Optional attributes
  account_kind = each.value.account_kind
  access_tier = contains(
    ["BlobStorage", "FileStorage", "StorageV2"],
    each.value.account_kind
  ) ? each.value.access_tier : null
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}

resource "azurerm_storage_account_static_website" "this" {
  for_each = var.storage_account_static_websites

  # Required attributes
  storage_account_id = azurerm_storage_account.this[each.value.storage_account_key].id

  # Optional attributes
  index_document     = each.value.index_document
  error_404_document = each.value.error_404_document
}

resource "azurerm_storage_container" "this" {
  for_each = var.storage_account_containers

  # Required attributes
  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.this[each.value.storage_account_key].id
  container_access_type = each.value.container_access_type
}