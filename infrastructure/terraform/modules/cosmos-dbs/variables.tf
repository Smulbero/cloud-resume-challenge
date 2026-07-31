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

  validation {
    condition = alltrue([
      for resource in var.cosmos_db_accounts :
      resource.consistency_policy.consistency_level == "BoundedStaleness" ||
      (
        resource.consistency_policy.max_interval_in_seconds == 5 &&
        resource.consistency_policy.max_staleness_prefix == 100
      )
    ])
    error_message = "max_interval_in_seconds and max_staleness_prefix can only be set to values other than default when the consistency_level is set to BoundedStaleness"
  }
}

variable "cosmos_db_tables" {
  type = map(object({
    resource_group_key   = string
    cosmosdb_account_key = string
    name                 = string
    throughput           = optional(number, 400)
  }))
  description = "Map of Cosmos DB objects to deploy"

  validation {
    condition = alltrue(
      [for resource in var.cosmos_db_tables : resource.throughput >= 400 && resource.throughput <= 1000000]
    )
    error_message = "Cosmos db manual throughput should be equal to or greater than 400 and less than or equal to 1000000."
  }
  validation {
    condition = alltrue(
      [for resource in var.cosmos_db_tables : resource.throughput % 100 == 0]
    )
    error_message = "Cosmos db throughput should be in increments of 100."
  }
}