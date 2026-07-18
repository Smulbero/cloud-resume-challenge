# Function App — Cosmos DB Table API Role Assignment

This document explains how the Function App authenticates to Azure Cosmos DB (Table API) and how to grant access to a new identity (local dev user, or the Function App's managed identity).

<details>
<summary>Disclaimer</summary>
This document was drafted with AI assistance (Claude) at the author's request. Steps have been manually verified against the official Microsoft documentation linked in [References](#references), but review with a critical eye before relying on it — especially if Azure's CLI/API surface for Cosmos DB Table RBAC changes (it was in preview at time of writing).
</details>

## Why this exists

The Function App uses `DefaultAzureCredential` (no keys, no connection strings) to talk to Cosmos DB. This works for both:

- **Local development** — falls back to your own `az login` session
- **Deployed Function App** — uses its system-assigned managed identity

However, Cosmos DB access is **not** granted through standard Azure RBAC (`az role assignment create`). Cosmos DB has its own **native, account-scoped data-plane RBAC system**, separate from normal Azure resource permissions. Regular Azure roles (Owner, Contributor, Cosmos DB Operator, etc.) only grant *control-plane* access (managing the account itself) — they do **not** grant permission to read/write data.

If an identity is missing a data-plane role assignment, you'll see errors like `Unauthorized` or `Forbidden` (`readMetadata` action blocked) when the app tries to read/write.

## One-time setup: granting data-plane access

Cosmos DB for Table doesn't have a dedicated `az cosmosdb` subcommand yet (unlike the NoSQL API's `az cosmosdb sql role assignment create`), so this is done via raw `az rest` calls.

### 1. Get the Cosmos DB account's resource ID

```bash
resourceId=$(az cosmosdb show \
  --resource-group "<resource-group-name>" \
  --name "<cosmos-account-name>" \
  --query "id" \
  --output tsv)

echo $resourceId   # sanity check — should NOT be empty
```

### 2. Find the built-in role definition ID

```bash
az rest \
  --method "GET" \
  --url "$resourceId/tableRoleDefinitions?api-version=2023-04-15"
```

Look for **"Cosmos DB Built-in Data Contributor"** (read + write) in the output and copy its full `id` value (the entire path, not just the trailing GUID).

### 3. Get the principal ID to grant access to

- **Your own identity (local dev):**
  ```bash
  az ad signed-in-user show --query id --output tsv
  ```
- **The Function App's managed identity (once deployed):** the `principalId` output when the managed identity is enabled on the Function App (visible in Azure Portal → Function App → Identity, or from Terraform output).

### 4. Create the role assignment

Create a JSON body file, e.g. `role-assignment.json`:

```json
{
  "properties": {
    "roleDefinitionId": "<full id copied from step 2>",
    "principalId": "<id from step 3>",
    "scope": "/"
  }
}
```

Then submit it with a **newly generated, random GUID** in the URL (this GUID just names the assignment record — it isn't looked up anywhere):

```bash
# generate a fresh GUID
uuidgen

az rest \
  --method "PUT" \
  --url "$resourceId/tableRoleAssignments/<new-guid>?api-version=2023-04-15" \
  --body @role-assignment.json
```

### 5. Verify

```bash
az rest \
  --method "GET" \
  --url "$resourceId/tableRoleAssignments?api-version=2023-04-15"
```

Confirm your `principalId` appears in the list with the correct `roleDefinitionId`.

## Important notes

- **`scope: "/"`** grants account-wide access. This is the simplest option for a single-container project; narrower scopes are possible but add complexity not needed here.
- **Repeat this for every identity that needs access** — your own user account (local dev) and the Function App's managed identity (production) are two *separate* role assignments.
- **This step is not automated in Terraform yet.** If the Function App is redeployed with a new managed identity, or a teammate needs local access, this process must be repeated manually.
- Managing this via Azure Portal isn't currently supported — it must be done via CLI (`az rest`), PowerShell (`Invoke-AzRestMethod`), or Bicep/ARM.

## References

- [Connect using role-based access control and Microsoft Entra ID — Azure Cosmos DB for Table](https://learn.microsoft.com/en-us/azure/cosmos-db/table/how-to-connect-role-based-access-control) — control-plane vs. data-plane distinction, `az rest` usage pattern
- [Use data plane role-based access control (preview) — Azure Cosmos DB for Table](https://learn.microsoft.com/en-us/azure/cosmos-db/table/security/how-to-grant-data-plane-role-based-access) — step-by-step for listing role definitions and creating role assignments via `az rest`
- [Quickstart: Use Azure Cosmos DB for Table with Azure SDK for Python](https://learn.microsoft.com/en-us/azure/cosmos-db/table/quickstart-python) — confirms `DefaultAzureCredential` support and basic client usage
- [Reference: data plane actions — Azure Cosmos DB for Table](https://learn.microsoft.com/en-us/azure/cosmos-db/table/security/reference-data-plane-actions) — full list of built-in role definitions and their permitted actions
- [az ad signed-in-user | Microsoft Learn](https://learn.microsoft.com/en-us/cli/azure/ad/signed-in-user) — retrieving your own principal ID for local-dev role assignments

*Last verified: 2026-07-18. Cosmos DB Table API's native RBAC was in preview as of this date — check the docs above for current status before assuming these steps are unchanged.*