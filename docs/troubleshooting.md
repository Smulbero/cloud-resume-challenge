# Troubleshooting Log

This document contains major issues encountered during the project, kept for future reference.

<details>
<summary>Disclaimer</summary>
This document was co-authored with AI, utilizing context and source materials provided by the repository owner. Final review and curation were performed by the human author.
</details>

## 1. Cosmos DB Table API

### Symptom

```
Error: (BadRequest) Request url is invalid.
Code: BadRequest
Microsoft.Azure.Documents.Common/2.14.0
```

### Cause

The endpoint URL passed to `TableServiceClient` used the wrong domain. Cosmos DB accounts expose multiple endpoint URIs depending on API. The Table API requires the `<account>.table.cosmos.azure.com` domain specifically, **not** the general `<account>.documents.azure.com` URI which is found on the database overview page.

### Fix

Double-check the exact endpoint value in app settings:

- ✅ `https://<account>.table.cosmos.azure.com:443/`
- ❌ `https://<account>.documents.azure.com:443/`

### Sources
- [Quickstart: Use Azure Cosmos DB for Table with Azure SDK for Python](https://learn.microsoft.com/en-us/azure/cosmos-db/table/quickstart-python)

## 2. Cosmos DB RBAC

### Symptom

Running the "standard" Azure RBAC command to grant access:

```bash
az role assignment create --assignee <id> --role <role> --scope <scope>
```

...fails or silently does nothing useful for Cosmos DB data access. Separately, missing this step entirely produces:

```
Request blocked by Auth ... does not have required RBAC permissions to perform
action [Microsoft.DocumentDB/databaseAccounts/readMetadata] on resource [/]
```

### Cause

Cosmos DB uses a **native, account-scoped data-plane RBAC system**, completely separate from standard Azure RBAC. `az role assignment create` only grants *control-plane* roles (Owner, Contributor, Cosmos DB Operator for managing the account itself). None of these grant data read/write access. Cosmos DB Table API doesn't yet have a dedicated `az cosmosdb` subcommand for this, so it must be done via raw `az rest` calls.

### Fix

RBAC for Cosmos DB Table API is granted via `az rest` calls.
See [backend/function-app/README.md](backend\function-app\README.md) for further details.

**Note**
- The GUID in the assignment URL is **invented by you** - it's just a unique name for the record, not a lookup key.
- Local dev (`az login` identity) and the deployed Function App (managed identity) are **two separate role assignments**, granting one does not grant the other.

### Sources
- [Connect to Azure Cosmos DB for Table using role-based access control and Microsoft Entra ID](https://learn.microsoft.com/en-us/azure/cosmos-db/table/how-to-connect-role-based-access-control?pivots=azure-portal)
- [Community Q&A: RBAC for cosmos DB Table API](https://learn.microsoft.com/en-us/answers/questions/5611805/rbac-for-cosmos-db-table-api)

