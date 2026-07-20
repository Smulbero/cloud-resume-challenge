variable "general_tags" {
  type        = map(string)
  description = "A mapping of global tags to assign to all resources"
  default     = {
    terraform = true
  }
}

variable "resource_type_prefix" {
  type = string
  description = "Prefix value for resource group name"
  default = "rg"

  validation {
    condition = can(regex("^[a-z0-9]+$", var.resource_type_prefix))
    error_message = "The resource group prefix must only contain lowercase alphanumeric characters (e.g. 'rg')"
  }
}

variable "resource_groups" {
    type = map(object({
      location = string
      tags = optional(map(string), {})
    }))
    description = "Map of resource group objects to deploy"

    validation {
      condition = alltrue([ 
        for rg in var.resource_groups : can(regex("^[a-z0-9]+$", rg.location))        
      ])
      error_message = "Resource group locations must only contain lowercase alphanumeric characters (e.g. 'eastus', 'northeurope')"
    }
}