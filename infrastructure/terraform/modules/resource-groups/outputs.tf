output "resource_groups" {
  type = map(any)
  description = "A map containing the full objects of the deployed resource groups"
  value = azurerm_resource_group.this
}

output "names" {
  type = map(string)
  description = "A mapping of keys to resource group names"
  value = {
    for k, v in azurerm_resource_group.this : k => v.name
  }
}