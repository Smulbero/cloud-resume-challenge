module "resource_groups" {
  source = "./modules/resource-groups"
  resource_groups = var.resource_groups
  general_tags = var.general_tags
}