variable "general_tags" {
  type        = map(string)
  description = "A mapping of global tags to assign to all resources"

  default = {
    terraform = true
  }
}

variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
  }))
  description = "Map of resource group objects name, and location"
}

variable "random_integer" {
  type = object({
    min = number
    max = number
  })
  description = "Min and Max values for random_integer resource"

  default = {
    min = 1000
    max = 9999
  }

  validation {
    condition     = var.random_integer.min < var.random_integer.max
    error_message = "Min value must be smaller than max value"
  }
}

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

  validation {
    condition = alltrue([
      for resource in var.storage_accounts :
      length(resource.name) >= 3 && length(resource.name) <= 24 - length(tostring(var.random_integer.max)) && can(regex("^[a-z0-9]+$", resource.name))
    ])
    error_message = "Storage Account name must be between 3 and 24 (minus length of random_integer, default 4) characters, all lowercased, and must not contain any special characters"
  }

  validation {
    condition = alltrue([
      for resource in var.storage_accounts :
      contains(["Standard", "Premium"], resource.account_tier)
    ])
    error_message = "Acceptable Storage Account tiers: 'Standard' and 'Premium'."
  }

  validation {
    condition = alltrue([
      for resource in var.storage_accounts :
      contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], resource.account_replication_type)
    ])
    error_message = "Acceptable Storage Account replication types: 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', and 'RAGZRS'"
  }
}