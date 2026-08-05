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
  description = "Prefix value for resources name"
  default     = "sp"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_prefix))
    error_message = "The service plan name prefix must only contain lowercase alphanumeric characters (e.g. 'sp')"
  }
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

  validation {
    condition = alltrue([
      for k in var.service_plans :
      contains(["Windows", "Linux", "WindowsContainer"], k.os_type)
    ])
    error_message = "Acceptable Service Plan OS types: 'Windows', 'Linux', and 'WindowsContainer'"
  }

  validation {
    condition = alltrue([
      for k in var.service_plans :
      contains(["FC1", "EP1", "EP2", "EP3"], k.sku_name)
    ])
    error_message = "Acceptable Service Plan SKUs: 'FC1', 'EP1', 'EP2', and 'EP3'"
  }
}