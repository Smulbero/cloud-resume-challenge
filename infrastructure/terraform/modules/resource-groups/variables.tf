variable "general_tags" {
  type        = map(string)
  description = "A mapping of global tags to assign to all resources"
  default = {
    terraform = true
  }
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix value for k group name"
  default     = "rg"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_prefix))
    error_message = "The k group name prefix must only contain lowercase alphanumeric characters (e.g. 'rg')"
  }
}

variable "resource_groups" {
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
  description = "Map of k group objects to deploy"

  validation {
    condition = alltrue([
      for k in var.resource_groups :
      can(regex("^[a-z0-9]+$", k.location))
    ])
    error_message = "k group locations must only contain lowercase alphanumeric characters (e.g. 'eastus', 'northeurope')"
  }
}