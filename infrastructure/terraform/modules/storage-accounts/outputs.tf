output "storage_accounts" {
  type        = map(any)
  description = "A map containing the full objects of the deployed storage accounts"
  value       = azurerm_storage_account.this
}

output "names" {
  type        = map(string)
  description = "A mapping of keys to storage account names"
  value = {
    for k, v in azurerm_storage_account.this : k => v.name
  }
}

output "storage_containers" {
  type        = map(any)
  description = "A map containing the full objects of the deployed storage containers"
  value       = azurerm_storage_container.this
}