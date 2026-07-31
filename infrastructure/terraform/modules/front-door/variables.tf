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

variable "frontdoor_profiles" {
  type = map(object({
    # Required attributes
    resource_group_key = string
    name               = string
    sku_name           = string

    # Optional attributes
    identity = optional(object({
      type = string
    }), {})
    response_timeout_seconds = optional(number, 120)
    log_scrubbing_rules = optional(map(object({
      match_variable = string
    })), null)
    tags = optional(map(string), {})
  }))
  description = "Map of front door profiles to deploy"

  validation {
    condition = alltrue(
      [for k in var.frontdoor_profiles : contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], k.sku_name)]
    )
    error_message = "Acceptable values for Azure Front Door SKUs: 'Standard_AzureFrontDoor', and 'Premium_AzureFrontDoor'"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_profiles : k.identity ?
        contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], k.identity.type) : true
      ]
    )
    error_message = "Acceptable values for identity blocks 'type' attribute: 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_profiles : k.log_scrubbing_rules ?
        alltrue(
          [for sub_key in k.log_scrubbing_rules : contains(["QueryStringArgNames", "RequestIPAddress", "RequestUri"], sub_key.match_variable)]
        ) : true
      ]
    )
    error_message = "Acceptable values for log scrubbing rule blocks 'match_variable' attribute: 'QueryStringArgNames', 'RequestIPAddress', and 'RequestUri'"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_profiles : k.response_timeout_seconds >= 16 && k.response_timeout_seconds <= 240]
    )
    error_message = "Acceptable values for 'response_timeout_seconds' attribute are between 16 and 240"
  }
}

variable "frontdoor_endpoints" {
  type = map(object({
    # Required attributes
    frontdoor_profile_key = string
    name                  = string

    # Optional attributes
    enabled = optional(bool, true)
    tags    = optional(map(string), {})
  }))
  description = "Map of front door endpoints to deploy"
}

variable "frontdoor_origin_groups" {
  type = map(object({
    # Required attributes
    frontdoor_profile_key = string
    name                  = string
    load_balancing = {
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    }

    # Optional attributes
    health_probe = optional(object({
      protocol            = string
      interval_in_seconds = number
      request_type        = optional(string, "HEAD")
      path                = optional(string, "/")
    }), null)
  }))
  description = "Map of front door origin groups to deploy"

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origin_groups : k.load_balancing.additional_latency_in_milliseconds >= 0 && k.load_balancing.additional_latency_in_milliseconds <= 1000]
    )
    error_message = "Acceptable values for load_balancing blocks 'additional_latency_in_milliseconds' attribute are between 0 and 1000"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origin_groups : k.load_balancing.sample_size >= 0 && k.load_balancing.sample_size <= 255]
    )
    error_message = "Acceptable values for load_balancing blocks 'sample_size' attribute are between 0 and 255"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origin_groups : k.load_balancing.successful_samples_required >= 0 && k.load_balancing.successful_samples_required <= 255]
    )
    error_message = "Acceptable values for load_balancing blocks 'successful_samples_required' attribute are between 0 and 255"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origin_groups : k.health_probe ?
      contains(["Http", "Https"], k.health_probe.protocol) : true]
    )
    error_message = "Acceptable values for health_probe blocks 'protocol' attribute are: 'Http', and 'Https'"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origin_groups : k.health_probe ?
      k.health_probe.interval_in_seconds >= 1 && k.health_probe.interval_in_seconds <= 255 : true]
    )
    error_message = "Acceptable values for health_probe blocks 'interval_in_seconds' attribute are between 1 and 255"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origin_groups : k.health_probe ?
      contains(["GET", "HEAD"], k.health_probe.request_type) : true]
    )
    error_message = "Acceptable values for health_probe blocks 'request_type' attribute are: 'GET', and 'HEAD'"
  }
}

variable "frontdoor_origins" {
  type = map(object({
    # Required attributes
    name                           = string
    frontdoor_origin_group_key     = string
    host_name                      = string
    certificate_name_check_enabled = bool

    # Optional attributes
    enabled            = optional(bool, true)
    http_port          = optional(number, 80)
    https_port         = optional(number, 443)
    origin_host_header = optional(string, null)
    priority           = optional(number, 1)   # 1-5
    weight             = optional(number, 500) # 1-1000
  }))
  description = "Map of front door origins to deploy"

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origins : k.http_port >= 1 && k.http_port <= 65535]
    )
    error_message = "Acceptable values for 'http_port' attribute are between 1 and 65535"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origins : k.https_port >= 1 && k.https_port <= 65535]
    )
    error_message = "Acceptable values for 'https_port' attribute are between 1 and 65535"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origins : k.priority >= 1 && k.priority <= 5]
    )
    error_message = "Acceptable values for 'priority' attribute are between 1 and 5"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_origins : k.weight >= 1 && k.weight <= 1000]
    )
    error_message = "Acceptable values for 'weight' attribute are between 1 and 1000"
  }
}

variable "frontdoor_routes" {
  type = map(object({
    # Required attributes
    name                       = string
    frontdoor_endpoint_key     = string
    frontdoor_origin_group_key = string
    patterns_to_match          = list(string)
    supported_protocols        = list(string)

    # Optional attributes
    frontdoor_origin_key        = optional(string, null)
    frontdoor_custom_domain_key = optional(string, null)
    frontdoor_origin_path_key   = optional(string, null)
    frontdoor_rule_set_key      = optional(string, null)
    enabled                     = optional(bool, true)
    https_redirect_enabled      = optional(bool, true)
    link_to_default_domain      = optional(bool, true)
    forwarding_protocol         = optional(string, "MatchRequest")
    cache = optional(object({
      query_string_caching_behavior = optional(string, "IgnoreQueryString")
      query_strings                 = optional(list, null)
      compression_enabled           = optional(bool, false)
      content_types_to_compress     = optional(list, null)
    }), null)
  }))
  description = "Map of front door routes to deploy"

  validation {
    condition = alltrue(
      [for k in var.frontdoor_routes : k.https_redirect_enabled == true ?
        k.supported_protocols == ["Http", "Https"] : true
      ]
    )
    error_message = "If 'https_redirect_enabled' attribute is set to 'true' the 'supported_protocols' attribute must contain both Http and Https values"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_routes : contains(["HttpOnly", "HttpsOnly", "MatchRequest"], k.forwarding_protocol)]
    )
    error_message = "Acceptable values for 'forwarding_protocol' attribute: 'HttpOnly', 'HttpsOnly', and 'MatchRequest'"
  }

  validation {
    condition = alltrue(
      [for k in var.frontdoor_routes : k.cache ?
      contains(["IgnoreQueryString", "IgnoreSpecifiedQueryStrings", "IncludeSpecifiedQueryStrings", "UseQueryString"], k.cache.query_string_caching_behavior) : true]
    )
    error_message = "Acceptable values for cache blocks 'query_string_caching_behavior' attribute: 'IgnoreQueryString', 'IgnoreSpecifiedQueryStrings', 'IncludeSpecifiedQueryStrings', and 'UseQueryString'"
  }
}