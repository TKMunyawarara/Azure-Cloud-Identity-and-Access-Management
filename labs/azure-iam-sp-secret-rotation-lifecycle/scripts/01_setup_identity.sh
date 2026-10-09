#!/usr/bin/env bash
# ==============================================================================
# Script Name:    01_setup_identity.sh
# Purpose:        Automate provision of Azure App Registration, Service Principal,
#                 and least-privilege RBAC role assignment.
# Author:         JInda CLoud (Cloud Security Engineering Lab)
# Prerequisites:  Azure CLI installed and authenticated (`az login`).
# ==============================================================================

set -euo pipefail

# Configurable Variables
APP_NAME="app-automation-scanner-dev"
RESOURCE_GROUP="appreg-rg"
ROLE_NAME="Reader"

echo "[+] Starting Identity Provisioning Flow..."

# 1. Verify Active Azure Session
echo "[*] Verifying Azure CLI authentication context..."
if ! az account show > /dev/null 2>&1; then
  echo "[-] ERROR: Not logged into Azure CLI. Run 'az login' first." >&2
  exit 1
fi

SUBSCRIPTION_NAME=$(az account show --query "name" -o tsv)
echo "[+] Active Subscription: ${SUBSCRIPTION_NAME}"

# 2. Check or Create Target Resource Group Scope
echo "[*] Verifying target Resource Group: ${RESOURCE_GROUP}..."
if ! az group show --name "${RESOURCE_GROUP}" > /dev/null 2>&1; then
  echo "[*] Creating Resource Group '${RESOURCE_GROUP}' in eastus..."
  az group create --name "${RESOURCE_GROUP}" --location "eastus" --tags Environment=Lab ManagedBy=CLI
fi

RG_SCOPE=$(az group show --name "${RESOURCE_GROUP}" --query "id" -o tsv)
echo "[+] Target Scope ID: ${RG_SCOPE}"

# 3. Provision App Registration (Blueprint)
echo "[*] Registering Application Blueprint in Entra ID: ${APP_NAME}..."
APP_ID=$(az ad app create --display-name "${APP_NAME}" --query "appId" -o tsv)
echo "[+] App Registration Created! Application ID (Client ID): ${APP_ID}"

# 4. Instantiate Service Principal (Local Identity Object)
echo "[*] Instantiating Service Principal for App ID: ${APP_ID}..."
SP_ID=$(az ad sp create --id "${APP_ID}" --query "id" -o tsv)
echo "[+] Service Principal Created! Object ID (Principal ID): ${SP_ID}"

# Pause briefly for Entra ID replication across tenant DCs
sleep 5

# 5. Apply Least-Privilege Azure RBAC Role
echo "[*] Assigning '${ROLE_NAME}' role to Service Principal scoped to '${RESOURCE_GROUP}'..."
az role assignment create \
  --assignee-object-id "${SP_ID}" \
  --assignee-principal-type "ServicePrincipal" \
  --role "${ROLE_NAME}" \
  --scope "${RG_SCOPE}" \
  --output json

echo ""
echo "=============================================================================="
echo " [SUCCESS] Identity Setup Complete!"
echo " Export the following variable in your terminal session for Script 02:"
echo " export APP_ID=\"${APP_ID}\""
echo "=============================================================================="