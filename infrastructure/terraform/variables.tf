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
    resource_group_key       = string
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

    container = optional(object({
      name                  = optional(string, null)
      container_access_type = optional(string, null)
    }), null)
  }))
  description = "Map of storage account objects to deploy"
}

# ==================================================
# Service Plans
# ==================================================
variable "service_plans" {
  type = map(object({
    # Required attributes
    resource_group_key = string
    name               = string
    os_type            = string
    sku_name           = string

    # Optional attributes
    tags = optional(map(string), {})
  }))
  description = "Map of service plan objects to deploy"
}

# ==================================================
# Function Apps
# ==================================================
variable "function_apps" {
  type = map(object({
    # Required attributes
    resource_group_key          = string
    storage_account_key         = string
    service_plan_key            = string
    name                        = string
    storage_container_type      = optional(string, "blobContainer")
    storage_authentication_type = optional(string, "SystemAssignedIdentity")
    runtime_name                = string
    runtime_version             = number

    # Optional attributes
    app_settings = optional(map(string), {})
    tags         = optional(map(string), {})
  }))
  description = "Map of function app objects to deploy"
}

# ==================================================
# Cosmos DBs
# ==================================================
variable "cosmos_db_accounts" {
  type = map(object({
    # Required attributes
    resource_group_key = string
    name               = string
    offer_type         = string
    geo_locations = map(object({
      failover_priority = number
      location          = string
      zone_redundant    = optional(bool, false)
    }))
    consistency_policy = object({
      consistency_level       = string
      max_interval_in_seconds = optional(number, 5)
      max_staleness_prefix    = optional(number, 100)
    })
    capabilities = map(object({
      name = string
    }))

    # Optional attributes
    tags = optional(map(string), {})
  }))
  description = "Map of Cosmos DB Account objects to deploy"
}

variable "cosmos_db_tables" {
  type = map(object({
    resource_group_key   = string
    cosmosdb_account_key = string
    name                 = string
    throughput           = optional(number, 400)
  }))
  description = "Map of Cosmos DB objects to deploy"
}