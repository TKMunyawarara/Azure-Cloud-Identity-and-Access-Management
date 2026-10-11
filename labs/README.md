# Azure IAM Privilege Escalation & Least-Privilege Remediation Lab

## Executive Summary
This lab demonstrates the risks associated with misconfigured Azure RBAC roles on non-human identities (Service Principals). In this environment, a Service Principal (`app-sp-vulnerable`) was provisioned with excessive permissions (`Contributor`) at a Resource Group scope (`rg-lab-foundations`). Using the Azure CLI, I performed a security assessment, analyzed scope inheritance mechanics, stripped excessive privileges, and enforced the Principle of Least Privilege by re-assigning the identity to the `Reader` role.

---

## Environment & Architecture

```text
[ Azure Subscription: 7bb17488-2aa1-46cd-a6b8-28dd281bbdd6 ]
       │
       └── [ Resource Group: rg-lab-foundations ]
              │
              ├── Inherited Roles: Subscription Owner (User Principal)
              └── Direct Assignment: app-sp-vulnerable (Service Principal)
                     ├── INITIAL:   Contributor (Over-Permissioned)
                     └── REMEDIATED: Reader (Least Privilege)
Threat Model & Attack Path
1. Threat Scenario
An application utilizing app-sp-vulnerable suffers an application-level vulnerability (e.g., Remote Code Execution or Hardcoded Secret Leak). An attacker extracts the Service Principal's client credentials.

2. Impact Analysis
Initial State (Contributor): The attacker gains broad management plane control over all resources in rg-lab-foundations. They can delete virtual machines, modify network security rules, wipe storage containers, or exfiltrate sensitive data.

Remediated State (Reader): The attacker's reach is limited to read-only metadata enumeration. They cannot modify, create, or destroy infrastructure assets within the resource group.

Lab Execution & Findings
Finding 1: Scope Inheritance vs. Direct Assignments
Querying Direct Assignments: Initial execution of az role assignment list --resource-group "rg-lab-foundations" returned an empty array, confirming no local role assignments existed directly at the resource group boundary.

Querying Inherited Assignments: Appending --include-inherited revealed 5 subscription-level assignments cascading down to the group, including the primary tenant administrative user holding Owner rights at /subscriptions/7bb17488-2aa1-46cd-a6b8-28dd281bbdd6.

Finding 2: Excessive Service Principal Rights
Initial Binding: app-sp-vulnerable was directly bound with Contributor rights on rg-lab-foundations.

Action Analysis: Inspection via az role definition list --name "Contributor" confirmed permission wildcarding (* on resource actions), representing an unacceptable blast radius for a workload only requiring status inspection.

Remediation & Validation
Role Revocation: Deleted the direct Contributor assignment for app-sp-vulnerable.

Least Privilege Binding: Applied the Reader role scoped strictly to rg-lab-foundations.

Audit Verification: Re-ran az role assignment list --resource-group "rg-lab-foundations" --output table to confirm the assignment updated successfully.

Evidence
Initial Direct Role Assignment Verification
Remediated Role Assignment Verification
Key Security Lessons Learned
Default CLI Filters Can Hide Inherited Risk: Default scope queries omit inherited subscription permissions. Audits must explicitly check --include-inherited to accurately assess total effective access.

Service Principals Are High-Value Targets: Workload identities often bypass MFA and conditional access policies. Over-permissioning a Service Principal creates a high-impact persistence and lateral movement path for attackers.

Infrastructure Scoping Matters: Scoping RBAC assignments to specific Resource Groups rather than the entire Subscription restricts the potential blast radius during credential compromise.
