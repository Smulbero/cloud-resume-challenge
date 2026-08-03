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
  description = "Map of k group objects name, and location"
}

variable "random_integer" {
  type = object({
    min = number
    max = number
  })
  description = "Min and Max values for random_integer k"

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
    tags         = optional(map(string), {})
  }))
  description = "Map of storage account objects to deploy"

  validation {
    condition = alltrue([
      for k in var.storage_accounts :
      length(k.name) >= 3 && length(k.name) <= 24 - length(tostring(var.random_integer.max)) &&
      can(regex("^[a-z0-9]+$", k.name))
    ])
    error_message = "Storage Account name must be between 3 and 24 (minus length of random_integer, default 4) characters, all lowercased, and must not contain any special characters"
  }

  validation {
    condition = alltrue([
      for k in var.storage_accounts :
      contains(["Standard", "Premium"], k.account_tier)
    ])
    error_message = "Acceptable Storage Account tiers: 'Standard' and 'Premium'."
  }

  validation {
    condition = alltrue([
      for k in var.storage_accounts :
      contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], k.account_replication_type)
    ])
    error_message = "Acceptable Storage Account replication types: 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', and 'RAGZRS'"
  }

  validation {
    condition = alltrue([
      for k in var.storage_accounts :
      contains(["Hot", "Cool", "Cold", "Smart", "Premium"], k.access_tier)
    ])
    error_message = "Acceptable Storage Account access tiers: 'Hot', 'Cool', 'Cold', 'Smart', and 'Premium'"
  }
}

variable "storage_account_static_websites" {
  type = map(object({
    storage_account_key = string
    index_document      = optional(string, "index.html")
    error_404_document  = optional(string, "404.html")
  }))
}

variable "storage_account_containers" {
  type = map(object({
    storage_account_key   = string
    name                  = string
    container_access_type = string
  }))
}