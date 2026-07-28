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

variable "storage_accounts" {
  type = map(object({
    name = string
  }))
  description = "Map of storage account objects name"
}

variable "service_plans" {
  type = map(object({
    id = string
  }))
  description = "Map of service plan objects id"
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix value for resource group name"
  default     = "fa"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_prefix))
    error_message = "The function app name prefix must only contain lowercase alphanumeric characters (e.g. 'fa')"
  }
}

variable "function_apps" {
  type = map(object({
    # Required attributes
    resource_group_key = string
    storage_account_key = string
    service_plan_key = string
    name = string
    site_config = optional((object({
      application_stack = optional(object({
        python_version = optional(string, null)
      }), {})
    })), {})

    # Optional attributes
    identity = {
      type = optional(string, "SystemAssigned")
      identity_ids = optional(list, [])
    }
    tags = optional(map(string), {})
  }))
  description = "Map of function app objects to deploy"

  validation {
    condition = alltrue(
      [ for resource in var.function_apps : lenght(resource.name) <= 32 - lenght(var.resource_name_prefix) - 1 ]
    )
    error_message = "value"
  }

  validation {
    condition = alltrue(
      [ for resource in var.function_apps : resource.site_config.application_stack.python_version != null ?
      contains(["3.14", "3.13", "3.12", "3.11", "3.10"], resource.site_config.application_stack.python_version) : true]
    )
    error_message = "Acceptable Python versions: '3.10', '3.11', '3.12', '3.13', and '3.14'"
  }
}