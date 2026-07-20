variable "general_tags" {
  type        = map(string)
  description = "A mapping of global tags to assign to all resources"
  default     = {
    terraform = true
  }
}

variable "resource_groups" {
  type = map(object({
      location = string
      tags = optional(map(string), {})
    }))
    description = "Map of resource group objects to deploy"
}