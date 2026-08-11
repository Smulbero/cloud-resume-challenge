resource "azurerm_function_app_flex_consumption" "this" {
  for_each = var.function_apps

  # Required attributes
  name = format(
    "%s-%s",
    var.resource_name_prefix,
    each.value.name
  )
  resource_group_name         = var.resource_groups[each.value.resource_group_key].name
  location                    = var.resource_groups[each.value.resource_group_key].location
  service_plan_id             = var.service_plans[each.value.service_plan_key].id
  storage_container_type      = each.value.storage_container_type
  storage_container_endpoint  = "${var.storage_accounts[each.value.storage_account_key].primary_blob_endpoint}${var.storage_containers[each.value.storage_account_key].name}"
  storage_authentication_type = each.value.storage_authentication_type
  runtime_name                = each.value.runtime_name
  runtime_version             = each.value.runtime_version
  maximum_instance_count      = 10
  instance_memory_in_mb       = 2048
  site_config {
    cors {
      allowed_origins = concat([var.frontdoor_endpoints[each.value.frontdoor_endpoint_key].host_name], each.value.site_config.cors.allowed_origins)
    }

    ip_restriction_default_action = "Deny"

    ip_restriction {
      name        = "AllowFrontDoor"
      service_tag = "AzureFrontDoor.Backend"
      priority    = 100
      action      = "Allow"

      headers {
        x_azure_fdid = [var.frontdoor_profiles[each.value.frontdoor_profile_key].resource_guid]
      }
    }
  }

  # Optional attributes
  app_settings = merge(
    { "AzureWebJobsStorage__accountName" = var.storage_accounts[each.value.storage_account_key].name },
    each.value.app_settings
  )
  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []

    content {
      # Required
      type = identity.value.type
    }
  }
  tags = merge(
    var.general_tags,
    each.value.tags
  )
}