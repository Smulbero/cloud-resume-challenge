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

variable "resource_name_prefix" {
  type        = string
  description = "Prefix value for resource group name"
  default     = "asp"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_prefix))
    error_message = "The app service plan name prefix must only contain lowercase alphanumeric characters (e.g. 'asp')"
  }
}

variable "service_plans" {
  type = map(object({
    # Required attributes
    resource_group_key = string
    name = string
    os_type = string
    sku_name = string

    # Optional attributes
    tags = optional(map(string), {})
  }))
  description = "Map of service plan objects to deploy"

  validation {
    condition = alltrue(
      [ for resource in var.service_plans: contains(["Windows", "Linux", "WindowsContainer"], resource.os_type) ]
    )
    error_message = "Acceptable Service Plan OS types: 'Windows', 'Linux', and 'WindowsContainer'"
  }
}