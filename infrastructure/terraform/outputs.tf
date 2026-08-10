output "resource_groups" {
  value = {
    for k, v in module.resource_groups.resource_groups : k => {
        name = v.name
      }
    }
}

output "cosmos_db_accounts" {
  value = {
    for k, v in module.cosmos_dbs.cosmos_db_accounts : k => {
      name = v.name
    }
  }
}

# output "function_app_identities" {
#   value = module.function_apps.function_app_identities
# }

output "function_apps_flex" {
  value = {
    for k, v in module.function_apps.function_apps_flex : k => {
      name = v.name
      principal_id = v.identity[*].principal_id
    } 
  }
}

output "frontdoor_custom_domain_validation_tokens" {
  value = module.frontdoors.frontdoor_custom_domain_validation_tokens
}

output "frontdoor_endpoint_hostnames" {
  value = module.frontdoors.frontdoor_endpoint_hostnames
}