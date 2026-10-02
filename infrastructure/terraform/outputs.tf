# ==================================================
# Resource Groups
# ==================================================
output "resource_groups" {
  description = "A mapping of keys to resource group names"
  value = {
    for k, v in module.resource_groups.resource_groups : k => {
      name = v.name
    }
  }
}

# ==================================================
# Cosmos DBs
# ==================================================
output "cosmos_db_accounts" {
  description = "A mapping of keys to cosmos db account names and ids"
  value = {
    for k, v in module.cosmos_dbs.cosmos_db_accounts : k => {
      name = v.name
      id   = v.id
    }
  }
}

# ==================================================
# Front Doors
# ==================================================
output "frontdoor_origins" {
  description = "A mapping of keys to front door origin names and host names"
  value = {
    for k, v in module.frontdoors.frontdoor_origins : k => {
      name      = v.name
      host_name = v.host_name
    }
  }
}

output "frontdoor_profiles" {
  value = {
    for k, v in module.frontdoors.frontdoor_profiles : k => {
      name = v.name
    }
  }
}

output "frontdoor_endpoints" {
  value = {
    for k, v in module.frontdoors.frontdoor_endpoints : k => {
      name = v.name
    }
  }
}

output "frontdoor_custom_domains" {
  value = {
    for k, v in module.frontdoors.frontdoor_custom_domains : k => {
      domain = v.host_name
    }
  }
}

output "frontdoor_endpoint_hostnames" {
  description = "A mapping of keys to front door endpoint host names"
  value       = module.frontdoors.frontdoor_endpoint_hostnames
}

# ==================================================
# Function Apps
# ==================================================
output "function_apps_flex" {
  description = "A mapping of keys to flex consumption function app names and their managed identity principal ids"
  value = {
    for k, v in module.function_apps.function_apps_flex : k => {
      name         = v.name
      principal_id = v.identity[0].principal_id
    }
  }
}

# ==================================================
# Storage Accounts
# ==================================================
output "storage_accounts" {
  description = "A mapping of keys to storage account names"
  value = {
    for k, v in module.storage_accounts.storage_accounts : k => {
      name = v.name
    }
  }
}

output "storage_containers" {
  description = "A mapping of keys to storage container names"
  value = {
    for k, v in module.storage_accounts.storage_containers : k => {
      name = v.name
    }
  }
}