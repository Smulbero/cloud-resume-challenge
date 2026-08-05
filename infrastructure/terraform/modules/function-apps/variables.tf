variable "general_tags" {
  type        = map(string)
  description = "A mapping of global tags to assign to all resources"
  default = {
    terraform = true
  }
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix value for resources name"
  default     = "fa"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_prefix))
    error_message = "The function app name prefix must only contain lowercase alphanumeric characters (e.g. 'fa')"
  }
}

variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
  }))
  description = "Map of resource group objects name, and location"
}

variable "storage_accounts" {
  type = map(object({
    name                  = string
    primary_blob_endpoint = string
  }))
  description = "Map of storage account objects name, and primary_blob_endpoint"
}

variable "storage_containers" {
  type = map(object({
    name = string
  }))
  description = "Map of storage container objects name"
}

variable "service_plans" {
  type = map(object({
    id = string
  }))
  description = "Map of service plan objects id"
}

variable "frontdoor_endpoints" {
  type = map(object({
    host_name = string
  }))
  description = "Map of frontdoor endpoint host names"
}

variable "frontdoor_profiles" {
  type = map(object({
    id = string
    resource_guid = string
  }))
  description = "Map of frontdoor profiles"
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

variable "function_apps" {
  type = map(object({
    # Required attributes
    resource_group_key          = string
    storage_account_key         = string
    service_plan_key            = string
    frontdoor_endpoint_key      = string
    frontdoor_profile_key       = string
    name                        = string
    storage_container_type      = optional(string, "blobContainer")
    storage_authentication_type = optional(string, "SystemAssignedIdentity")
    runtime_name                = string
    runtime_version             = number
    site_config = object({
      cors = optional(object({
        allowed_origins = optional(list(string), [])
      }), null)
    })

    # Optional attributes
    app_settings = optional(map(string), {})
    identity = optional(object({
      type = optional(string, "SystemAssigned")
    }), null)
    tags = optional(map(string), {})
  }))
  description = "Map of function app objects to deploy"

  validation {
    condition = alltrue([
      for k in var.function_apps :
      length(k.name) <= 32 - length(var.resource_name_prefix) - 1 # -1 from '-' between name prefix and the name
    ])
    error_message = "value"
  }

  validation {
    condition = alltrue([
      for k in var.function_apps :
      contains(["node", "dotnet-isolated", "powershell", "python", "java", "custom"], k.runtime_name)
    ])
    error_message = "Acceptable runtime names: 'node', 'dotnet-isolated', 'powershell', 'python', 'java', and 'custom'"
  }

  validation {
    condition = alltrue([
      for k in var.function_apps :
      k.runtime_name == "python" ?
      contains([3.14, 3.13, 3.12, 3.11, 3.10], k.runtime_version) :
      true
    ])
    error_message = "Acceptable Python versions: '3.10', '3.11', '3.12', '3.13', and '3.14'"
  }
}