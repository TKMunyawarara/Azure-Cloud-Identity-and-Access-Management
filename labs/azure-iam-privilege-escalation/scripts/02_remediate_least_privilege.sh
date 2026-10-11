#!/usr/bin/env bash
# ==============================================================================
# Script Name: 02_remediate_least_privilege.sh
# Description: Revokes excessive Contributor role from Service Principal and
#              applies Reader role to enforce Least Privilege.
# ==============================================================================

set -euo pipefail

RG_NAME="rg-lab-foundations"
SP_NAME="app-sp-vulnerable"

echo "[+] Fetching Principal ID for ${SP_NAME}..."
SP_ID=$(az ad sp list --display-name "$SP_NAME" --query "[0].id" -o tsv)

echo "[+] Revoking Contributor role..."
az role assignment delete --assignee "$SP_ID" --role "Contributor" --resource-group "$RG_NAME"

echo "[+] Assigning restricted Reader role..."
az role assignment create --assignee "$SP_ID" --role "Reader" --resource-group "$RG_NAME"

echo "[+] Verification: Auditing updated role assignments..."
az role assignment list --resource-group "$RG_NAME" --output table
