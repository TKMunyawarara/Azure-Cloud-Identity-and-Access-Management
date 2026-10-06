## Lab Index & Security Matrix

| Lab Directory | Focus Domain | Key Security Concepts | Primary Tools / APIs | Status |
| :--- | :--- | :--- | :--- | :--- |
| [01-conditional-access-boundary](labs/01-conditional-access-boundary/) | Zero-Trust Access | Contextual Auth, MFA, Trusted Locations, Device Health | Entra ID, Conditional Access | `VERIFIED` |
| [02-custom-rbac-enforcement](labs/02-custom-rbac-enforcement/) | Azure Authorization | Custom Roles, Scope Limitation, Least Privilege | Azure ARM, Azure CLI, PowerShell | `VERIFIED` |
| [03-administrative-units-least-privilege](labs/03-administrative-units-least-privilege/) | Identity Governance | Administrative Units (AUs), Delegated Admin Boundaries | Entra ID, Graph API | `VERIFIED` |
| [04-managed-identity-sec-lab](labs/04-managed-identity-sec-lab/) | Workload Security | Credential-less Auth, System/User Managed Identities, Token Abuse Mitigation | Azure IMDS, Managed Identity, Key Vault | `VERIFIED` |

## Public Repository Redaction Standard
All raw logs, CLI commands, HTTP traffic captures, and scripts across this repository adhere to standard secret-sanitization guidelines. Tenant IDs, Subscription IDs, object IDs, IP addresses, and session tokens have been replaced with placeholders (`<TENANT_ID>`, `<SUBSCRIPTION_ID>`, `<TARGET_IP>`, `<REDACTED>`).
