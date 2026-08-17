<!-- BEGIN_TF_DOCS -->
# Module: cloudflare/cloudflare-dns-records

Creates one or more Cloudflare DNS Records from a map of definitions.

## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [cloudflare_dns_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloudflare_zone_id"></a> [cloudflare\_zone\_id](#input\_cloudflare\_zone\_id) | The Cloudflare Zone ID that DNS records will be created in | `string` | n/a | yes |
| <a name="input_dns_records"></a> [dns\_records](#input\_dns\_records) | Map of DNS record objects to create | <pre>map(object({<br/>    name    = string<br/>    type    = string<br/>    content = string<br/>    proxied = optional(bool, false)<br/>    ttl     = optional(number, 3600)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dns_records"></a> [dns\_records](#output\_dns\_records) | A map containing the full objects of the deployed DNS records |
<!-- END_TF_DOCS -->