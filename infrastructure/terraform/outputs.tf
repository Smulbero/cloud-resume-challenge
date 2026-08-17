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
      id = v.id
    }
  }
}

output "frontdoor_origins" {
  value = {
    for k, v in module.frontdoors.frontdoor_origins : k => {
      name      = v.name
      host_name = v.host_name
    }
  }
}

output "function_apps_flex" {
  value = {
    for k, v in module.function_apps.function_apps_flex : k => {
      name         = v.name
      principal_id = v.identity[0].principal_id
    }
  }
}

output "frontdoor_custom_domain_validation_tokens" {
  value = module.frontdoors.frontdoor_custom_domain_validation_tokens
}

output "frontdoor_endpoint_hostnames" {
  value = module.frontdoors.frontdoor_endpoint_hostnames
}

output "storage_accounts" {
  value = {
    for k, v in module.storage_accounts.storage_accounts : k => {
      name = v.name
    }
  }
}

output "storage_containers" {
  value = {
    for k, v in module.storage_accounts.storage_containers : k => {
      name = v.name
    }
  }
}