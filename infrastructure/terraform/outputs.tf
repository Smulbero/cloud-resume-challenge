output "resource_group_names" {
  value = module.resource_groups.resource_group_names
}

output "cosmos_db_names" {
  value = module.cosmos_dbs.cosmos_db_names
}

output "function_app_identities" {
  value = module.function_apps.function_app_identities
}

output "frontdoor_custom_domain_validation_tokens" {
  value = module.frontdoors.frontdoor_custom_domain_validation_tokens
}

output "frontdoor_endpoint_hostnames" {
  value = module.frontdoors.frontdoor_endpoint_hostnames
}