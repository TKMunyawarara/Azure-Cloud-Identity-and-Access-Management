#!/usr/bin/env bash
# ==============================================================================
# Script Name:    02_rotate_credentials.sh
# Purpose:        Execute zero-downtime secret rotation and legacy key pruning
#                 for an existing App Registration.
# Prerequisites:  APP_ID environment variable set (`export APP_ID="<your-app-id>"`).
# ==============================================================================

set -euo pipefail

echo "[+] Starting Zero-Downtime Secret Rotation Workflow..."

# 1. Validate Target APP_ID Variable
if [[ -z "${APP_ID:-}" ]]; then
  echo "[-] ERROR: APP_ID environment variable is not set." >&2
  echo "    Run: export APP_ID=\"<your-application-id>\" before executing." >&2
  exit 1
fi

echo "[+] Target Application ID: ${APP_ID}"

# 2. Append Short-Lived Legacy Secret (Secret-Key-V1)
END_DATE_V1=$(date -u -d "+1 day" +%Y-%m-%d)
echo "[*] Appending 'Secret-Key-V1' (Expires: ${END_DATE_V1})..."
az ad app credential reset \
  --id "${APP_ID}" \
  --append \
  --display-name "Secret-Key-V1" \
  --end-date "${END_DATE_V1}" \
  --output json > /dev/null

# 3. Append Rotated Production Secret (Secret-Key-V2)
END_DATE_V2=$(date -u -d "+90 days" +%Y-%m-%d)
echo "[*] Appending 'Secret-Key-V2' (Expires: ${END_DATE_V2})..."
az ad app credential reset \
  --id "${APP_ID}" \
  --append \
  --display-name "Secret-Key-V2" \
  --end-date "${END_DATE_V2}" \
  --output json > /dev/null

# 4. Display Dual-Secret Active Audit State
echo ""
echo "[+] AUDIT: Current Active Credentials (Dual-Secret Phase):"
az ad app credential list --id "${APP_ID}" --output table

# 5. Extract Key ID for Secret-Key-V1 Safely via JMESPath Query
echo ""
echo "[*] Querying KeyId for legacy credential 'Secret-Key-V1'..."
V1_KEY_ID=$(az ad app credential list --id "${APP_ID}" --query "[?displayName=='Secret-Key-V1'].keyId" -o tsv)

if [[ -z "${V1_KEY_ID}" ]]; then
  echo "[-] ERROR: Could not locate KeyId for Secret-Key-V1." >&2
  exit 1
fi

echo "[+] Located Legacy KeyId: ${V1_KEY_ID}"

# 6. Revoke Legacy Credential
echo "[*] Revoking Secret-Key-V1 (${V1_KEY_ID})..."
az ad app credential delete \
  --id "${APP_ID}" \
  --key-id "${V1_KEY_ID}"

# 7. Final Hardened Audit
echo ""
echo "[+] FINAL AUDIT: Credentials Post-Rotation (Only Secret-Key-V2 should remain):"
az ad app credential list --id "${APP_ID}" --output table

echo ""
echo "[SUCCESS] Zero-Downtime Secret Rotation Completed Successfully!"