variable "general_tags" {
  type        = map(string)
  description = "A mapping of global tags to assign to all resources"
  default = {
    terraform = true
  }
}

locals {
  general_tags = merge(
    { deployedDate = formatdate("DD-MM-YYYY", timestamp()) },
    var.general_tags
  )
}

# ==================================================
# Resource Groups
# ==================================================
variable "resource_groups" {
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
  description = "Map of resource group objects to deploy"
}

# ==================================================
# Storage Accounts
# ==================================================
variable "storage_accounts" {
  type = map(object({
    # Required attributes
    name                     = string
    account_tier             = string
    account_replication_type = string

    # Optional attributes
    account_kind = optional(string, "Storage")
    access_tier  = optional(string, "Hot")
    static_website = optional(object({
      index_document     = optional(string, "index.html")
      error_404_document = optional(string, "404.html")
    }))
    tags = optional(map(string), {})
  }))
  description = "Map of storage account objects to deploy"
}