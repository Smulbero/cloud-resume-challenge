output "frontdoor_profiles" {
  type        = map(any)
  description = "A map containing the full objects of the deployed Azure Front Door profiles"
  value       = azurerm_cdn_frontdoor_profile.this
}

output "frontdoor_endpoints" {
  type        = map(any)
  description = "A map containing the full objects of the deployed Azure Front Door endpoints"
  value       = azurerm_cdn_frontdoor_endpoint.this
}

output "frontdoor_origin_groups" {
  type        = map(any)
  description = "A map containing the full objects of the deployed Azure Front Door origin groups"
  value       = azurerm_cdn_frontdoor_origin_group.this
}

output "frontdoor_origins" {
  type        = map(any)
  description = "A map containing the full objects of the deployed Azure Front Door origins"
  value       = azurerm_cdn_frontdoor_origin.this
}

output "frontdoor_routes" {
  type        = map(any)
  description = "A map containing the full objects of the deployed Azure Front Door routes"
  value       = azurerm_cdn_frontdoor_route.this
}