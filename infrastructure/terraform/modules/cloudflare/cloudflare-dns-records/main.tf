/*
 * # Module: cloudflare/cloudflare-dns-records
 *
 * Creates one or more Cloudflare DNS Records from a map of definitions.
 */

resource "cloudflare_dns_record" "this" {
  for_each = var.dns_records

  # Required attributes
  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.proxied ? 1 : each.value.ttl

  # Optional attributes
  content = each.value.content
  proxied = each.value.proxied
}