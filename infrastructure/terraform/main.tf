module "resource_groups" {
  source          = "./modules/resource-groups"
  resource_groups = var.resource_groups
  general_tags    = local.general_tags
}

module "storage_accounts" {
  source           = "./modules/storage-accounts"
  resource_groups  = module.resource_groups.resource_groups
  storage_accounts = var.storage_accounts
  general_tags     = local.general_tags
}