output "cosmos_db_accounts" {
  type        = map(any)
  description = "A map containing the full objects of the deployed cosmos db accounts"
  value       = azurerm_cosmosdb_account.this
}

output "cosmos_db_tables" {
  type        = map(any)
  description = "A map containing the full objects of the deployed cosmos db tables"
  value       = azurerm_cosmosdb_table.this
}