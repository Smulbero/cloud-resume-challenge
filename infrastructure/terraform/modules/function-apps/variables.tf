variable "general_tags" {
  type        = map(string)
  description = "A mapping of global tags to assign to all resources"
  default = {
    terraform = true
  }
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

  validation {
    condition = alltrue(
      [for resource in var.function_apps : length(resource.name) <= 32 - length(var.resource_name_prefix) - 1] # -1 from '-' between name prefix and the name
    )
    error_message = "value"
  }

  validation {
    condition = alltrue(
      [for resource in var.function_apps :
        contains(["node", "dotnet-isolated", "powershell", "python", "java", "custom"], resource.runtime_name)
      ]
    )
    error_message = "Acceptable runtime names: 'node', 'dotnet-isolated', 'powershell', 'python', 'java', and 'custom'"
  }

  validation {
    condition = alltrue(
      [for resource in var.function_apps :
        resource.runtime_name == "python" ?
        contains([3.14, 3.13, 3.12, 3.11, 3.10], resource.runtime_version) :
        true
      ]
    )
    error_message = "Acceptable Python versions: '3.10', '3.11', '3.12', '3.13', and '3.14'"
  }
}