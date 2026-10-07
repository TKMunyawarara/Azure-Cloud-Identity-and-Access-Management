# Azure Just-In-Time (JIT) Access & Least-Privilege Enforcement (PIM Simulation)

## Executive Summary
Permanent, continuous administrative access ("standing privileges") represents one of the highest identity risks in cloud security. If an administrative credential or session token is stolen, an adversary gains immediate, unmonitored operational control. 

This project implements and documents a **Just-In-Time (JIT) Role Elevation and Automated Revocation Engine** using custom Bash orchestration over Azure Resource Manager (ARM) APIs. It simulates the core mechanics of **Microsoft Entra Privileged Identity Management (PIM)** on standard Azure infrastructure, proving how time-bound, least-privilege scoping eliminates standing access and reduces the blast radius of identity compromise.

---

## Technical Architecture & Operational Flow

              [ Baseline Identity: sec-operator ]
                              │
                              ▼
       ┌──────────────────────────────────────────────┐
       │ Phase 1: Pre-JIT Baseline (Zero Access)       │
       │ Scope: /subscriptions/.../rg-jit-simulation  │
       │ Action: az storage account create            │
       │ Status: DENIED (403 AuthorizationFailed)     │
       └──────────────────────────────────────────────┘
                              │
                              ▼
       ┌──────────────────────────────────────────────┐
       │ Phase 2: Active JIT Elevation (10 Min Window)│
       │ Trigger: Script assigns Contributor via ARM  │
       │ Action: az storage account create            │
       │ Status: ALLOWED (200 Succeeded)              │
       └──────────────────────────────────────────────┘
                              │
                              ▼
       ┌──────────────────────────────────────────────┐
       │ Phase 3: Automated JIT Expiration            │
       │ Trigger: Sleep timer expires -> Role deleted │
       │ Token Cache Invalidation: az account clear   │
       │ Action: az storage account create            │
       │ Status: DENIED (403 AuthorizationFailed)     │
       └──────────────────────────────────────────────┘

---

## Threat Model & Attack Surface Analysis

| Element | Security Specification |
| :--- | :--- |
| **Target Asset** | Azure Resource Group (`rg-jit-simulation`) and child storage infrastructure |
| **Identity Principal** | `sec-operator@<domain>.onmicrosoft.com` |
| **Threat Vector** | Credential harvesting / AiTM session token theft targeting identity operators |
| **Attack Scenario** | An attacker gains valid session credentials for `sec-operator` at 02:00 AM |
| **Mitigation (JIT)** | Identity holds **Zero Standing Privileges**. Attacker execution fails immediately. Role elevation requires an explicit API call, justification logging, and time-boxed auto-expiring assignments |
| **Scope Boundary** | Explicitly restricted to Resource Group scope (`rg-jit-simulation`) rather than Subscription scope |

---

## Verification & Lifecycle Evidence

### Lifecycle State Validation

| Lifecycle Phase | Active Role Assignment | Execution Command | Result | Security Baseline | Evidence Reference |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Phase 1: Pre-JIT** | Reader (Subscription Scope) | `az storage account create` | ❌ **403 Forbidden** | Zero Standing Access / Deny by Default | `evidence/before_JIT.png` |
| **Phase 2: JIT Window** | Contributor (RG Scope) | `az storage account create` | ✅ **200 OK (Succeeded)** | Least Privilege / Scoped Window | `evidence/during_JIT.png` |
| **Phase 3: Post-JIT** | None (Revoked) | `az storage account create` | ❌ **403 Forbidden** | Automated Expiration / Zero Standing Access | 
