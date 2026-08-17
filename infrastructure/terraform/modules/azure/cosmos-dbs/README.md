<!-- BEGIN_TF_DOCS -->
# Module: azure/cosmos-dbs

Creates one or more of the following Azure Cosmos DB resources from a map of definitions:
- Cosmos DB Account
- Cosmos DB Table

## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_cosmosdb_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cosmos_db_accounts"></a> [cosmos\_db\_accounts](#input\_cosmos\_db\_accounts) | Map of Cosmos DB Account objects to deploy | <pre>map(object({<br/>    # Required attributes<br/>    resource_group_key = string<br/>    name               = string<br/>    offer_type         = string<br/>    geo_locations = map(object({<br/>      failover_priority = number<br/>      location          = string<br/>      zone_redundant    = optional(bool, false)<br/>    }))<br/>    consistency_policy = object({<br/>      consistency_level       = string<br/>      max_interval_in_seconds = optional(number, 5)<br/>      max_staleness_prefix    = optional(number, 100)<br/>    })<br/>    capabilities = map(object({<br/>      name = string<br/>    }))<br/><br/>    # Optional attributes<br/>    tags = optional(map(string), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_cosmos_db_tables"></a> [cosmos\_db\_tables](#input\_cosmos\_db\_tables) | Map of Cosmos DB Table objects to deploy | <pre>map(object({<br/>    resource_group_key   = string<br/>    cosmosdb_account_key = string<br/>    name                 = string<br/>    throughput           = optional(number, 400)<br/>  }))</pre> | n/a | yes |
| <a name="input_general_tags"></a> [general\_tags](#input\_general\_tags) | A mapping of global tags to assign to all resources | `map(string)` | <pre>{<br/>  "terraform": true<br/>}</pre> | no |
| <a name="input_random_integer"></a> [random\_integer](#input\_random\_integer) | Min and Max values for random\_integer k | <pre>object({<br/>    min = number<br/>    max = number<br/>  })</pre> | <pre>{<br/>  "max": 9999,<br/>  "min": 1000<br/>}</pre> | no |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Map of resource group objects name, and location | <pre>map(object({<br/>    name     = string<br/>    location = string<br/>  }))</pre> | n/a | yes |
| <a name="input_resource_name_prefix"></a> [resource\_name\_prefix](#input\_resource\_name\_prefix) | Prefix value for resources name | `string` | `"cdb"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cosmos_db_account_endpoints"></a> [cosmos\_db\_account\_endpoints](#output\_cosmos\_db\_account\_endpoints) | A cosmos db account endpoints |
| <a name="output_cosmos_db_accounts"></a> [cosmos\_db\_accounts](#output\_cosmos\_db\_accounts) | A map containing the full objects of the deployed cosmos db accounts |
| <a name="output_cosmos_db_names"></a> [cosmos\_db\_names](#output\_cosmos\_db\_names) | A mapping of keys to cosmos db names |
| <a name="output_cosmos_db_tables"></a> [cosmos\_db\_tables](#output\_cosmos\_db\_tables) | A map containing the full objects of the deployed cosmos db tables |
<!-- END_TF_DOCS -->