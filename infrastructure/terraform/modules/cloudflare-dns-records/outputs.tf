output "dns_records" {
  type        = map(any)
  description = "A map containing the full objects of the deployed DNS records"
  value       = cloudflare_dns_record.this
}