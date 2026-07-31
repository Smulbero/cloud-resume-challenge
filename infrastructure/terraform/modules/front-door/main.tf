resource "random_integer" "this" {
  for_each = var.frontdoor_profiles

  # Required attributes
  min = var.random_integer.min
  max = var.random_integer.max
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
    for_each = each.value.identity != null

    content {
      type = each.value.identity.type
    }
  }
  dynamic "log_scrubbing_rule" {
    for_each = each.value.log_scrubbing_rules != null

    content {
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
  dynamic "load_balancing" {
    for_each = each.value.load_balancing != null
    
    content {
      # Optional
      additional_latency_in_milliseconds = load_balancing.value.additional_latency_in_milliseconds
      sample_size                        = load_balancing.value.sample_size
      successful_samples_required        = load_balancing.value.successful_samples_required
    }
  }

  # Optional attributes
  dynamic "health_probe" {
    for_each = each.value.health_probe != null

    content {
      # Required
      protocol            = health_probe.value.health_probe.protocol
      interval_in_seconds = health_probe.value.health_probe.interval_in_seconds
      # Optional
      request_type = health_probe.value.health_probe.request_type
      path         = health_probe.value.health_probe.path

    }
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = var.frontdoor_origins

  # Required attributes
  name                           = each.value.name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this[each.value.frontdoor_origin_group_key].id
  host_name                      = each.value.host_name
  certificate_name_check_enabled = each.value.certificate_name_check_enabled

  # Optional attributes
  enabled            = each.value.enabled
  http_port          = each.value.http_port
  https_port         = each.value.https_port
  origin_host_header = each.value.origin_host_header
  priority           = each.value.priority
  weight             = each.value.weight
}

resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  for_each = var.frontdoor_custom_domains

  # Required attributes
  name = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[each.value.frontdoor_profile_key].id
  host_name = each.value.host_name
  dynamic "tls" {
    for_each = each.value.tls != null

    content {
      # Optional
      certificate_type = each.value.tls.certificate_type
      minimum_version = each.value.tls.minimum_version
    }
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
  cdn_frontdoor_origin_ids        = each.value.frontdoor_origin_key != null ? [azurerm_cdn_frontdoor_origin.this[each.value.frontdoor_origin_key]] : null
  cdn_frontdoor_custom_domain_ids = each.value.frontdoor_custom_domain_key != null ? [azurerm_cdn_frontdoor_custom_domain.this[each.value.frontdoor_custom_domain_key].id] : null
  # cdn_frontdoor_origin_path = [placeholder, not sure if can be used]
  # cdn_frontdoor_rule_set_ids = [placeholder, not sure if can be used]
  enabled                = each.value.enabled
  https_redirect_enabled = each.value.https_redirect_enabled
  link_to_default_domain = each.value.link_to_default_domain
  forwarding_protocol    = each.value.forwarding_protocol
  dynamic "cache" {
    for_each = each.value.cache != null

    content {
      # Optional
      query_string_caching_behavior = each.value.cache.query_string_caching_behavior
      query_strings                 = each.value.cache.query_strings
      compression_enabled           = each.value.cache.compression_enabled
      content_types_to_compress     = each.value.cache.content_types_to_compress

    }
  }
}