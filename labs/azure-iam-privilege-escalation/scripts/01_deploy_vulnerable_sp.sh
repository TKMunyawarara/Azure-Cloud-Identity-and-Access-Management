#!/usr/bin/env bash
# ==============================================================================
# Script Name: 01_deploy_vulnerable_sp.sh
# Description: Provisions resource group boundary and creates an over-permissioned
#              Service Principal with Contributor access at the RG scope.
# ==============================================================================

set -euo pipefail

RG_NAME="rg-lab-foundations"
LOCATION="eastus"
SP_NAME="app-sp-vulnerable"

echo "[+] Creating Resource Group: ${RG_NAME}..."
az group create --name "$RG_NAME" --location "$LOCATION" --tags Environment=Lab Owner=MentorStudent --output table

echo "[+] Fetching Resource Group Resource ID..."
RG_ID=$(az group show --name "$RG_NAME" --query id -o tsv)

echo "[+] Provisioning Service Principal with explicit Contributor assignment..."
az ad sp create-for-rbac --name "$SP_NAME" --role "Contributor" --scopes "$RG_ID" --output json

echo "[+] Audit: Direct Role Assignments on ${RG_NAME}:"
az role assignment list --resource-group "$RG_NAME" --output table
