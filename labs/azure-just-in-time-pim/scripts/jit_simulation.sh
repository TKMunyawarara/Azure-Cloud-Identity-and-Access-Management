#!/bin/bash
# ==============================================================================
# Script Name: jit_simulation.sh
# Purpose:     Simulates Just-In-Time (JIT) Role Elevation & Auto-Revocation
# Security Concept: Least Privilege & Time-Bound Access (Entra ID PIM Simulation)
# ==============================================================================

# 1. Dynamic Variables Resolution
SUB_ID=$(az account show --query id -o tsv)
DOMAIN=$(az rest --method get --url "https://graph.microsoft.com/v1.0/domains" --query "value[?isDefault].id" -o tsv)

TARGET_USER="sec-operator@${DOMAIN}"
TARGET_RG="rg-jit-simulation"
SCOPE="/subscriptions/${SUB_ID}/resourceGroups/${TARGET_RG}"
ROLE="Contributor"
DURATION_SECONDS=600  # 10 minutes active JIT window

echo "============================================================"
echo "[*] INITIATING JIT ACCESS ELEVATION PIPELINE"
echo "[*] Target Identity: $TARGET_USER"
echo "[*] Target Scope:    $SCOPE"
echo "[*] Assigned Role:   $ROLE"
echo "[*] Window Duration: $DURATION_SECONDS seconds"
echo "============================================================"

# 2. Grant Temporary Access (JIT Activation)
echo -e "\n[+] Step 1: Assigning JIT Role..."
az role assignment create \
  --assignee "$TARGET_USER" \
  --role "$ROLE" \
  --scope "$SCOPE" \
  --output table

if [ $? -eq 0 ]; then
  echo "[✓] Role successfully assigned."
else
  echo "[!] Failed to assign role. Exiting."
  exit 1
fi

# 3. Active Window Counter
echo -e "\n[+] Step 2: JIT Access Window is now ACTIVE."
echo "[!] User $TARGET_USER has 10 minutes to execute authorized tasks."
echo "[*] Waiting for expiration timer ($DURATION_SECONDS seconds)..."

# Sleep for the designated duration (Simulating active work window)
sleep $DURATION_SECONDS

# 4. Automatic Revocation (JIT Expiration)
echo -e "\n[-] Step 3: JIT Window Expired. Initiating Auto-Revocation..."
az role assignment delete \
  --assignee "$TARGET_USER" \
  --role "$ROLE" \
  --scope "$SCOPE"

echo "[✓] JIT Access revoked. Target identity returned to Zero Standing Access state."
echo "============================================================"