variable "cloudflare_zone_id" {
  type        = string
  description = "The Cloudflare Zone ID that DNS records will be created in"
  sensitive   = true
}

variable "dns_records" {
  type = map(object({
    name    = string
    type    = string
    content = string
    proxied = optional(bool, false)
    ttl     = optional(number, 3600)
  }))
  description = "Map of DNS record objects to create"

  validation {
    condition = alltrue([
      for k in var.dns_records :
      contains(["A", "AAAA", "CNAME", "TXT", "MX", "NS"], k.type)
    ])
    error_message = "Acceptable DNS record types: 'A', 'AAAA', 'CNAME', 'TXT', 'MX', and 'NS'"
  }
}