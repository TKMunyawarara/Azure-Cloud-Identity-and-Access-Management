## Lab Index & Security Matrix

| Lab Directory | Focus Domain | Key Security Concepts | Primary Tools / APIs | Status |
| :--- | :--- | :--- | :--- | :--- |
| [01-conditional-access-boundary](labs/azure-conditional-access-boundary/) | Zero-Trust Access | Contextual Auth, MFA, Trusted Locations, Device Health | Entra ID, Conditional Access | `VERIFIED` |
| [02-custom-rbac-enforcement](labs/azure-custom-rbac-enforcement/) | Azure Authorization | Custom Roles, Scope Limitation, Least Privilege | Azure ARM, Azure CLI, PowerShell | `VERIFIED` |
| [03-administrative-units-least-privilege](labs/azure-iam-au-least-privilege/) | Identity Governance | Administrative Units (AUs), Delegated Admin Boundaries | Entra ID, Graph API | `VERIFIED` |
| [04-managed-identity-sec-lab](labs/azure-managed-identity-sec/) | Workload Security | Credential-less Auth, System/User Managed Identities, Token Abuse Mitigation | Azure IMDS, Managed Identity, Key Vault | `VERIFIED` |
| [05-just-in-time-pim](labs/azure-just-in-time-pim]/) | Identity & Governance | Zero Standing Access (ZSA), Just-In-Time (JIT) Elevation, Time-Bound RBAC, Token Cache Invalidation | Azure CLI, ARM APIs, Bash | Completed |
| [06-sp-secret-rotation-lifecycle](labs/azure-sp-secret-rotation-lifecycle/) | Identity & Secrets | App Registrations, Service Principals, Zero-Downtime Secret Rotation, Scoped RBAC | Azure CLI, Microsoft Entra ID | Completed |
| [07-detecting-hardcoded-credentials](labs/detecting-hardcoded-credentials/) | DevSecOps & Secrets | Secret Leakage Detection, Pre-commit Enforcement, Image Layer Scanning, Managed Identity Remediation | Gitleaks, Trivy, Git Hooks, Docker, Azure CLI | 'Completed' |
## Public Repository Redaction Standard
All raw logs, CLI commands, HTTP traffic captures, and scripts across this repository adhere to standard secret-sanitization guidelines. Tenant IDs, Subscription IDs, object IDs, IP addresses, and session tokens have been replaced with placeholders (`<TENANT_ID>`, `<SUBSCRIPTION_ID>`, `<TARGET_IP>`, `<REDACTED>`).
