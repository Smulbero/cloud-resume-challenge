# 7. Authentication Between Azure Functions and Cosmos DB

Date: 2026-07-24

## Status

Accepted

## Context

Azure Functions needs a secure way to access Azure Cosmos DB Table API to read and update the visitor counter.

## Decision

Azure Cosmos DB Table API supports authentication via Managed Identity, using the `DefaultAzureCredential`[¹], rather than a connection string or account key. Azure Functions will interact with the database directly using its Managed Identity.

Azure Key Vault could be used to store a Cosmos DB connection string. The Function would still need its own Managed Identity to authenticate to Key Vault, then retrieve and use the connection string to authenticate to Cosmos DB afterwards. This adds an unnecessary extra hop and resource.

[¹]: https://learn.microsoft.com/en-us/azure/cosmos-db/table/quickstart-python "Quickstart - Azure SDK for Python - Azure Cosmos DB for Table"

## Consequences

**Positive**
- Connection strings or account keys don't exist in code
- No additional Key Vault resource needed. Simpler configuration and less maintenance
- Access can be managed via RBAC

**Negative**
- Requires RBAC configuration in Terraform
- If project grows past the initial goal post, and later needs to store secrets, Key Vault may still need to be introduced