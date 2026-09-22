# ==================================================
# Resource Groups
# ==================================================
resource_groups = {
  cloudresumechallenge = {
    location = "westeurope"
  }
}

# ==================================================
# Storage Accounts
# ==================================================
storage_accounts = {
  frontend = {
    resource_group_key       = "cloudresumechallenge"
    name                     = "crcfrontend"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    blob_properties = {}
  },
  visitorcounter = {
    resource_group_key       = "cloudresumechallenge"
    name                     = "crcfuncapp"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    blob_properties = {}
  },
  tfstate = {
    resource_group_key       = "cloudresumechallenge"
    name                     = "tfstate"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    blob_properties = {
      versioning_enabled = true
    }
  }
}

storage_account_static_websites = {
  cloudresumechallenge = {
    storage_account_key = "frontend"
    index_document      = "index.html"
    error_404_document  = "404.html"
  }
}

storage_account_containers = {
  visitorcounter = {
    storage_account_key   = "visitorcounter"
    name                  = "facontainer"
    container_access_type = "private"
  },
  tfstate = {
    storage_account_key   = "tfstate"
    name                  = "tfstate"
    container_access_type = "private"
  }
}

# ==================================================
# Service Plans
# ==================================================
service_plans = {
  visitorcounter = {
    resource_group_key = "cloudresumechallenge"
    name               = "fa-visitorcounter"
    os_type            = "Linux"
    sku_name           = "FC1"
  }
}

# ==================================================
# Function Apps
# ==================================================
function_apps = {
  visitorcounter = {
    resource_group_key     = "cloudresumechallenge"
    storage_account_key    = "visitorcounter"
    service_plan_key       = "visitorcounter"
    frontdoor_endpoint_key = "cloudresumechallenge"
    frontdoor_profile_key  = "cloudresumechallenge"
    name                   = "visitorcounter"
    runtime_name           = "python"
    runtime_version        = 3.14
    site_config = {
      cors = {
        allowed_origins = ["crc.smulbero.com"]
      }
    }

    app_settings = {
      COSMOS_TABLE_ENDPOINT = "https://cdb-crc-account.table.cosmos.azure.com:443/"
      COSMOS_TABLE_NAME     = "crc-table"
      PARTITION_KEY         = "visitor-count"
      ROW_KEY               = "visitor-count"
    }
    identity = {
      type = "SystemAssigned"
    }
  }
}

# ==================================================
# Cosmos DBs
# ==================================================
cosmos_db_accounts = {
  crccdbaccount = {
    resource_group_key = "cloudresumechallenge"
    function_app_key   = "visitorcounter"
    name               = "cdb-crc-account"
    offer_type         = "Standard"
    geo_locations = {
      geo_location_one = {
        failover_priority = 0
        location          = "westeurope"
      }
    }
    consistency_policy = {
      consistency_level = "BoundedStaleness"
    }
    capabilities = {
      table = {
        name = "EnableTable"
      }
    }
  }
}

cosmos_db_tables = {
  crcTable = {
    resource_group_key   = "cloudresumechallenge"
    cosmosdb_account_key = "crccdbaccount"
    name                 = "crc-table"
  }
}

# ==================================================
# Front Doors
# ==================================================
frontdoor_profiles = {
  cloudresumechallenge = {
    resource_group_key = "cloudresumechallenge"
    name               = "crc-profile"
    sku_name           = "Standard_AzureFrontDoor"
  }
}

frontdoor_custom_domains = {
  cloudresumechallenge = {
    name                  = "crc-custom-domain"
    frontdoor_profile_key = "cloudresumechallenge"
    host_name             = "crc.smulbero.com"
    tls = {
      certificate_type = "ManagedCertificate"
    }
  }
}

frontdoor_endpoints = {
  cloudresumechallenge = {
    frontdoor_profile_key = "cloudresumechallenge"
    name                  = "crc-endpoint"
  }
}

frontdoor_origin_groups = {
  cloudresumechallenge = {
    frontdoor_profile_key = "cloudresumechallenge"
    name                  = "crc-origin-group"
    load_balancing        = {}
  },
  api = {
    frontdoor_profile_key = "cloudresumechallenge"
    name                  = "api-origin-group"
    load_balancing        = {}
    health_probe = {
      protocol            = "Https"
      interval_in_seconds = 30
      request_type        = "GET"
      path                = "/api/healthprobe"
    }
  }
}

frontdoor_origins = {
  cloudresumechallenge = {
    frontdoor_origin_group_key     = "cloudresumechallenge"
    name                           = "crc-origin"
    storage_account_key            = "frontend"
    certificate_name_check_enabled = false
  },
  api = {
    name                           = "api-origin"
    frontdoor_origin_group_key     = "api"
    host_name                      = "fa-visitorcounter.azurewebsites.net"
    certificate_name_check_enabled = true
  }
}

frontdoor_routes = {
  cloudresumechallenge = {
    name                        = "crc-route"
    frontdoor_endpoint_key      = "cloudresumechallenge"
    frontdoor_origin_group_key  = "cloudresumechallenge"
    frontdoor_origin_key        = "cloudresumechallenge"
    frontdoor_custom_domain_key = "cloudresumechallenge"
    patterns_to_match           = ["/*"]
    supported_protocols         = ["Http", "Https"]
    cache = {
      query_string_caching_behavior = "IgnoreQueryString"
      compression_enabled           = true
      content_types_to_compress = [
        "text/css",
        "text/html",
        "text/javascript",
        "text/js",
      ]
    }
  },
  api = {
    name                        = "api-route"
    frontdoor_endpoint_key      = "cloudresumechallenge"
    frontdoor_origin_group_key  = "api"
    frontdoor_origin_key        = "api"
    frontdoor_custom_domain_key = "cloudresumechallenge"
    patterns_to_match           = ["/api/*"]
    supported_protocols         = ["Http", "Https"]
    forwarding_protocol         = "HttpsOnly"
    https_redirect_enabled      = true
  }
}

frontdoor_firewall_policies = {
  cloudresumechallenge = {
    name                  = "crcwafpolicy"
    resource_group_key    = "cloudresumechallenge"
    frontdoor_profile_key = "cloudresumechallenge"
    mode                  = "Prevention"

    custom_rules = {
      apiratelimit = {
        name                           = "ApiRateLimiter"
        action                         = "Block"
        type                           = "RateLimitRule"
        priority                       = 100
        rate_limit_duration_in_minutes = 1
        rate_limit_threshold           = 5
        match_conditions = {
          apipath = {
            match_variable = "RequestUri"
            match_values   = ["/api/"]
            operator       = "Contains"
          }
        }
      },
      botblockerone = {
        name     = "BlockCommonBots"
        action   = "Block"
        type     = "MatchRule"
        priority = 110
        match_conditions = {
          commonbots = {
            match_variable = "RequestHeader"
            match_values = [
              "bot",
              "crawler",
              "spider",
              "probe",
              "health",
              "azure"
            ]
            operator   = "Contains"
            selector   = "User-Agent"
            transforms = ["Lowercase"]
          }
        }
      }
    }
  }
}

frontdoor_security_policies = {
  cloudresumechallenge = {
    name                          = "crcsecuritypolicy"
    frontdoor_profile_key         = "cloudresumechallenge"
    frontdoor_firewall_policy_key = "cloudresumechallenge"
    frontdoor_custom_domain_key   = "cloudresumechallenge"
  }
}