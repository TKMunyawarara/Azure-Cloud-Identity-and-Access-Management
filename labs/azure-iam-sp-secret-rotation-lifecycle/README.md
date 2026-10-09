# Azure Entra ID: Service Principal Lifecycle & Zero-Downtime Secret Rotation

## Executive Summary
This lab demonstrates the secure administration of non-human workload identities in Microsoft Entra ID (formerly Azure AD). It covers creating an App Registration and Service Principal, enforcing least-privilege Azure RBAC at a restricted resource group scope, executing a zero-downtime secret rotation workflow, and auditing identity state using the Azure CLI.

---

## Architecture & Identity Flow

[ Entra ID Tenant ]
│
▼
[ App Registration: app-automation-scanner-dev ]  <-- Holds Client Secrets (V1 / V2)
│
├─────────────────────────┐
▼                         ▼
[ Service Principal ]    [ Local Azure RBAC ]
(Object ID / Runtime)    └─ Role: Reader
└─ Scope: /resourceGroups/rg-p1-foundation-eastus


---

## Security Objectives
1. **Machine Identity Governance:** Differentiate between global application definitions (App Registrations) and local security principals (Service Principals).
2. **Blast Radius Control:** Limit non-human identity access using scoped RBAC assignments instead of subscription-level administrative roles.
3. **Zero-Downtime Credential Lifecycle:** Append replacement secrets prior to decommissioning legacy credentials to prevent service disruptions.

---

## Threat Model & Risk Analysis

| Vulnerability / Risk | Severity | Security Impact | Remediation Applied |
| :--- | :--- | :--- | :--- |
| **Over-Permissioned Service Principal** | High | Excessive subscription-level permissions allow full resource compromise if credentials leak. | Enforced **Reader** role restricted exclusively to `rg-p1-foundation-eastus`. |
| **Stale / Unexpiring Client Secrets** | High | Hardcoded long-lived secrets increase exposure windows for credential theft. | Enforced explicit 90-day secret lifetimes (`--end-date`). |
| **Outage During Secret Swaps** | Medium | Overwriting secrets instantly breaks running applications dependent on old keys. | Used `--append` flag to maintain dual-secret validity during app migration. |

---

## Execution & Rotation Workflow

### Step 1: Provision Workload Identity & Scoped RBAC
```bash
# 1. Register App Blueprint
APP_ID=$(az ad app create --display-name "app-automation-scanner-dev" --query "appId" -o tsv)

# 2. Instantiate Service Principal
SP_ID=$(az ad sp create --id $APP_ID --query "id" -o tsv)

# 3. Assign Reader Role at Resource Group Scope
RG_SCOPE=$(az group show --name rg-p1-foundation-eastus --query "id" -o tsv)

az role assignment create \
  --assignee-object-id $SP_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Reader" \
  --scope $RG_SCOPE
Step 2: Simulate Zero-Downtime Secret Rotation
To prevent application downtime, a replacement secret (Secret-Key-V2) is appended alongside the legacy secret (Secret-Key-V1):

Bash
# Append new 90-day rotated secret
END_DATE_V2=$(date -u -d "+90 days" +%Y-%m-%d)

az ad app credential reset \
  --id $APP_ID \
  --append \
  --display-name "Secret-Key-V2" \
  --end-date $END_DATE_V2
Evidence & Verification
1. Dual-Secret Audit State (Transition Phase)
During the rotation window, both credentials exist simultaneously, allowing dependent applications to switch keys without authentication failures:

Plaintext
DisplayName    EndDateTime           Hint    KeyId                                 StartDateTime
-------------  --------------------  ------  ------------------------------------  --------------------
Secret-Key-V2  2027-01-07T00:00:00Z  9gM     75d22640-42c1-4ed0-9f7d-ac32f0415a62  2026-10-09T06:12:44Z
Secret-Key-V1  2026-10-10T00:00:00Z  V4d     164470f2-82c7-4843-b591-2fdc65370bd0  2026-10-09T06:11:31Z
2. Legacy Credential Revocation
Once application configuration updates are confirmed, the old credential key is deleted:

Bash
az ad app credential delete --id $APP_ID --key-id 164470f2-82c7-4843-b591-2fdc65370bd0
3. Final Hardened State
Auditing credentials shows only the rotated 90-day secret active:

Plaintext
DisplayName    EndDateTime           Hint    KeyId                                 StartDateTime
-------------  --------------------  ------  ------------------------------------  --------------------
Secret-Key-V2  2027-01-07T00:00:00Z  9gM     75d22640-42c1-4ed0-9f7d-ac32f0415a62  2026-10-09T06:12:44Z
Key Lessons Learned & Architectural Guidance
Never use --append omitting flags during rotation: Overwriting secrets immediately triggers application outages.

Audit Key IDs carefully before deletion: Deleting the wrong KeyId revokes active credentials rather than legacy ones.

Strategic Identity Evolution: For production Azure workloads, static client secrets should eventually be replaced by Azure Managed Identities or Workload Identity Federation (OIDC) to eliminate password management entirely.
