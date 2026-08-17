#!/bin/bash
API_VERSION="2024-08-15"
# ==================================================
# Get necessary resource ids
# ==================================================
read -p "Function App key used for Terraform: " fa_key
read -p "Cosmos DB Account key used for Terraform: " cdb_key
echo "Getting resource ids.."
function_app_principal_id=$(terraform output -json function_apps_flex | jq -r ".$fa_key.principal_id")
cosmos_db_account_id=$(terraform output -json cosmos_db_accounts | jq -r ".$cdb_key.id")


cosmos_db_data_reader_id=$(az rest \
  --method "GET" \
  --url "$cosmos_db_account_id/tableRoleDefinitions?api-version=$API_VERSION" \
  --query "value[?contains(properties.roleName, 'Cosmos DB Built-in Data Reader')].id" \
  --output tsv)

cosmos_db_data_contributor_id=$(az rest \
  --method "GET" \
  --url "$cosmos_db_account_id/tableRoleDefinitions?api-version=$API_VERSION" \
  --query "value[?contains(properties.roleName, 'Cosmos DB Built-in Data Contributor')].id" \
  --output tsv)

# ==================================================
# Write out the permission files
# ==================================================
echo "Writing the permission files.."
TEMP_DIR=$(mktemp -d)

cat > "$TEMP_DIR/reader.json" <<EOF
{
  "properties": {
    "scope": "$cosmos_db_account_id",
    "roleDefinitionId": "$cosmos_db_data_reader_id",
    "principalId": "$function_app_principal_id"
  }
}
EOF

cat > "$TEMP_DIR/contributor.json" <<EOF
{
  "properties": {
    "scope": "$cosmos_db_account_id",
    "roleDefinitionId": "$cosmos_db_data_contributor_id",
    "principalId": "$function_app_principal_id"
  }
}
EOF

# ==================================================
# Assign the permissions
# ==================================================
echo "Assigning the permissions.."
uuid=$(powershell.exe -Command "[guid]::NewGuid().toString()")
az rest \
  --method "PUT" \
  --url "$cosmos_db_account_id/tableRoleAssignments/$uuid?api-version=$API_VERSION" \
  --body @$TEMP_DIR/reader.json

uuid=$(powershell.exe -Command "[guid]::NewGuid().toString()")
az rest \
  --method "PUT" \
  --url "$cosmos_db_account_id/tableRoleAssignments/$uuid?api-version=$API_VERSION" \
  --body @$TEMP_DIR/contributor.json

echo "Clean up the files.."
rm -rf $TEMP_DIR

# # # ==================================================
# # # Verification
# # # ==================================================
echo "Verification.."
az rest \
  --method "GET" \
  --url "$cosmos_db_account_id/tableRoleAssignments?api-version=$API_VERSION"