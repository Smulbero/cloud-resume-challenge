resource "time_static" "this" {}
locals {
  general_tags = merge(
    { deployedDate = formatdate("DD-MM-YYYY", time_static.this.rfc3339) },
    var.general_tags
  )
}

# ==================================================
# Resource Groups
# ==================================================
module "resource_groups" {
  source          = "./modules/resource-groups"
  resource_groups = var.resource_groups
  general_tags    = local.general_tags
}

# ==================================================
# Storage Accounts
# ==================================================
module "storage_accounts" {
  source                          = "./modules/storage-accounts"
  resource_groups                 = module.resource_groups.resource_groups
  storage_accounts                = var.storage_accounts
  storage_account_static_websites = var.storage_account_static_websites
  storage_account_containers      = var.storage_account_containers
  general_tags                    = local.general_tags
}

# ==================================================
# Service Plans
# ==================================================
module "service_plans" {
  source          = "./modules/service-plans"
  resource_groups = module.resource_groups.resource_groups
  service_plans   = var.service_plans
  general_tags    = local.general_tags
}

# ==================================================
# Cosmos DBs
# ==================================================
module "cosmos_dbs" {
  source             = "./modules/cosmos-dbs"
  resource_groups    = module.resource_groups.resource_groups
  cosmos_db_accounts = var.cosmos_db_accounts
  cosmos_db_tables   = var.cosmos_db_tables
  general_tags       = local.general_tags
}

# ==================================================
# Front Doors
# ==================================================
module "frontdoors" {
  source                      = "./modules/front-doors"
  resource_groups             = module.resource_groups.resource_groups
  storage_accounts            = module.storage_accounts.storage_accounts
  frontdoor_profiles          = var.frontdoor_profiles
  frontdoor_endpoints         = var.frontdoor_endpoints
  frontdoor_origin_groups     = var.frontdoor_origin_groups
  frontdoor_origins           = var.frontdoor_origins
  frontdoor_custom_domains    = var.frontdoor_custom_domains
  frontdoor_routes            = var.frontdoor_routes
  frontdoor_firewall_policies = var.frontdoor_firewall_policies
  frontdoor_security_policies = var.frontdoor_security_policies
  general_tags                = local.general_tags
}

# ==================================================
# Function Apps
# ==================================================
module "function_apps" {
  source              = "./modules/function-apps"
  resource_groups     = module.resource_groups.resource_groups
  storage_accounts    = module.storage_accounts.storage_accounts
  storage_containers  = module.storage_accounts.storage_containers
  service_plans       = module.service_plans.service_plans
  frontdoor_endpoints = module.frontdoors.frontdoor_endpoints
  frontdoor_profiles  = module.frontdoors.frontdoor_profiles
  function_apps       = var.function_apps
  general_tags        = local.general_tags
}

# ==================================================
# Cloudflare DNS Records
# ==================================================
locals {
  cloudflare_dns_records = merge(
    {
      for k, v in module.frontdoors.frontdoor_custom_domain_validation_tokens : "${k}-validation" => {
        name    = "_dnsauth.${var.frontdoor_custom_domains[k].host_name}"
        type    = "TXT"
        content = "\"${v.validation_token}\""
      }
    },
    {
      for k, v in module.frontdoors.frontdoor_endpoint_hostnames : "${k}-cname" => {
        name    = var.frontdoor_custom_domains[k].host_name
        type    = "CNAME"
        content = v.host_name
      }
    }
  )
}

module "cloudflare_dns_records" {
  source             = "./modules/cloudflare-dns-records"
  cloudflare_zone_id = var.cloudflare_zone_id
  dns_records        = local.cloudflare_dns_records
}

# ==================================================
# Role Assignments
# ==================================================
locals {
  role_assignments = merge(
    {
      for k, v in module.function_apps.function_apps_flex : "${k}-blob-owner" => {
        scope                = module.storage_accounts.storage_accounts[k].id
        principal_id         = v.identity[0].principal_id
        role_definition_name = "Storage Blob Data Owner"
      }
    }
  )
}

module "role_assignments" {
  source           = "./modules/role-assignments"
  role_assignments = local.role_assignments
}