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
  source           = "./modules/storage-accounts"
  resource_groups  = module.resource_groups.resource_groups
  storage_accounts = var.storage_accounts
  general_tags     = local.general_tags
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
# Function Apps
# ==================================================
module "function_apps" {
  source             = "./modules/function-apps"
  resource_groups    = module.resource_groups.resource_groups
  storage_accounts   = module.storage_accounts.storage_accounts
  storage_containers = module.storage_accounts.storage_containers
  service_plans      = module.service_plans.service_plans
  function_apps      = var.function_apps
  general_tags       = local.general_tags
}

# ==================================================
# Cosmos DBs
# ==================================================
module "cosmos_dbs" {
  source             = "./modules/cosmos-dbs"
  resource_groups    = module.resource_groups.resource_groups
  cosmos_db_accounts = var.cosmos_db_accounts
  cosmos_db_tables   = var.cosmos_db_tables
  general_tags       = var.general_tags
}