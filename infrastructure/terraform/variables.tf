variable "general_tags" {
  type        = map(string)
  description = "A mapping of global tags to assign to all resources"
  default = {
    terraform = true
  }
}

locals {
  general_tags = merge(
    { deployedDate = formatdate("DD-MM-YYYY", timestamp()) },
    var.general_tags
  )
}

# ==================================================
# Resource Groups
# ==================================================
variable "resource_groups" {
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
  description = "Map of resource group objects to deploy"
}

# ==================================================
# Storage Accounts
# ==================================================
variable "storage_accounts" {
  type = map(object({
    # Required attributes
    resource_group_key       = string
    name                     = string
    account_tier             = string
    account_replication_type = string

    # Optional attributes
    account_kind = optional(string, "Storage")
    access_tier  = optional(string, "Hot")
    tags         = optional(map(string), {})
  }))
  description = "Map of storage account objects to deploy"
}

variable "storage_account_static_websites" {
  type = map(object({
    storage_account_key = string
    index_document      = optional(string, "index.html")
    error_404_document  = optional(string, "404.html")
  }))
}

variable "storage_account_containers" {
  type = map(object({
    storage_account_key   = string
    name                  = string
    container_access_type = string
  }))
}

# ==================================================
# Service Plans
# ==================================================
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
}

# ==================================================
# Function Apps
# ==================================================
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
}

# ==================================================
# Cosmos DBs
# ==================================================
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
}

variable "cosmos_db_tables" {
  type = map(object({
    resource_group_key   = string
    cosmosdb_account_key = string
    name                 = string
    throughput           = optional(number, 400)
  }))
  description = "Map of Cosmos DB objects to deploy"
}

# ==================================================
# Front Doors
# ==================================================
variable "frontdoor_profiles" {
  type = map(object({
    # Required attributes
    resource_group_key = string
    name               = string
    sku_name           = string

    # Optional attributes
    identity = optional(object({
      type = optional(string, "SystemAssigned")
    }), null)
    response_timeout_seconds = optional(number, 120)
    log_scrubbing_rules = optional(map(object({
      match_variable = string
    })), null)
    tags = optional(map(string), {})
  }))
  description = "Map of front door profiles to deploy"
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
    load_balancing = object({
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    })

    # Optional attributes
    health_probe = optional(object({
      protocol            = string
      interval_in_seconds = number
      request_type        = optional(string, "HEAD")
      path                = optional(string, "/")
    }), null)
  }))
  description = "Map of front door origin groups to deploy"
}

variable "frontdoor_origins" {
  type = map(object({
    # Required attributes
    name                           = string
    frontdoor_origin_group_key     = string
    storage_account_key            = optional(string)
    host_name                      = optional(string)
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
}

variable "frontdoor_custom_domains" {
  type = map(object({
    name                  = string
    frontdoor_profile_key = string
    host_name             = string
    tls = object({
      certificate_type = optional(string, "ManagedCertificate")
      minimum_version  = optional(string, "TLS12")
    })
  }))
  description = "Map of front door custom domains to deploy"
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
      query_strings                 = optional(list(string), null)
      compression_enabled           = optional(bool, false)
      content_types_to_compress     = optional(list(string), null)
    }), null)
  }))
  description = "Map of front door routes to deploy"
}