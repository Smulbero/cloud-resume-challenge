resource "random_integer" "this" {
  for_each = var.frontdoor_profiles

  # Required attributes
  min = var.random_integer.min
  max = var.random_integer.max

  keepers = {
    ran_int = each.key
  }
}

resource "azurerm_cdn_frontdoor_profile" "this" {
  for_each = var.frontdoor_profiles

  # Required attributes
  name = format(
    "%s-%s-%s",
    var.resource_name_prefix,
    each.value.name,
    random_integer.this[each.key].result
  )
  resource_group_name = var.resource_groups[each.value.resource_group_key].name
  sku_name            = each.value.sku_name

  # Optional attributes
  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []

    content {
      # Required
      type = identity.value.type
    }
  }

  dynamic "log_scrubbing_rule" {
    for_each = each.value.log_scrubbing_rules != null ? each.value.log_scrubbing_rules : {}

    content {
      # Required
      match_variable = log_scrubbing_rule.value.match_variable
    }
  }

  response_timeout_seconds = each.value.response_timeout_seconds
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  for_each = var.frontdoor_endpoints

  # Required attributes
  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[each.value.frontdoor_profile_key].id

  # Optional attributes
  enabled = each.value.enabled
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each = var.frontdoor_origin_groups

  # Required attributes
  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[each.value.frontdoor_profile_key].id
  load_balancing {
    # Optional
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
  }

  # Optional attributes
  dynamic "health_probe" {
    for_each = each.value.health_probe != null ? [each.value.health_probe] : []

    content {
      # Required
      protocol            = health_probe.value.protocol
      interval_in_seconds = health_probe.value.interval_in_seconds
      # Optional
      request_type = health_probe.value.request_type
      path         = health_probe.value.path
    }
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = var.frontdoor_origins

  # Required attributes
  name                           = each.value.name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this[each.value.frontdoor_origin_group_key].id
  host_name                      = each.value.storage_account_key != null ? var.storage_accounts[each.value.storage_account_key].primary_web_host : each.value.host_name
  certificate_name_check_enabled = each.value.certificate_name_check_enabled

  # Optional attributes
  enabled    = each.value.enabled
  http_port  = each.value.http_port
  https_port = each.value.https_port
  origin_host_header = each.value.origin_host_header != null ? each.value.origin_host_header : (
    each.value.storage_account_key != null ? var.storage_accounts[each.value.storage_account_key].primary_web_host : each.value.host_name
  )
  priority = each.value.priority
  weight   = each.value.weight
}

resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  for_each = var.frontdoor_custom_domains

  # Required attributes
  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[each.value.frontdoor_profile_key].id
  host_name                = each.value.host_name

  tls {
    # Optional
    certificate_type = each.value.tls.certificate_type
    minimum_version  = each.value.tls.minimum_version
  }
}

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = var.frontdoor_routes

  # Required attributes
  name                          = each.value.name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this[each.value.frontdoor_endpoint_key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.value.frontdoor_origin_group_key].id
  patterns_to_match             = each.value.patterns_to_match
  supported_protocols           = each.value.supported_protocols

  # Optional attributes
  cdn_frontdoor_origin_ids        = each.value.frontdoor_origin_key != null ? [azurerm_cdn_frontdoor_origin.this[each.value.frontdoor_origin_key].id] : null
  cdn_frontdoor_custom_domain_ids = each.value.frontdoor_custom_domain_key != null ? [azurerm_cdn_frontdoor_custom_domain.this[each.value.frontdoor_custom_domain_key].id] : null
  enabled                         = each.value.enabled
  https_redirect_enabled          = each.value.https_redirect_enabled
  link_to_default_domain          = each.value.link_to_default_domain
  forwarding_protocol             = each.value.forwarding_protocol
  dynamic "cache" {
    for_each = each.value.cache != null ? [each.value.cache] : []

    content {
      # Optional
      query_string_caching_behavior = cache.value.query_string_caching_behavior
      query_strings                 = cache.value.query_strings
      compression_enabled           = cache.value.compression_enabled
      content_types_to_compress     = cache.value.content_types_to_compress
    }
  }
}