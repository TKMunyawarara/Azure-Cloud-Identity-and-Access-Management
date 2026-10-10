#Cloud Credential Leakage Detection & Automated Remediation Lab

## Executive Summary
This project demonstrates end-to-end detection, prevention, and architectural remediation of hardcoded cloud credentials across source code repositories and container image layers. Using **Gitleaks** and **Trivy**, I implemented automated pre-commit controls to block secret leaks at the developer workstation and analyzed container build artifacts to detect exposed credentials in Docker image layers.

## Key Objectives
- **Detection:** Audit Git commit history and Docker image layers for exposed Azure/AWS credentials and private keys.
- **Prevention:** Deploy a local Git `pre-commit` hook and custom Gitleaks configuration (`.gitleaks.toml`) to enforce client-side commit blocking.
- **Remediation:** Refactor container configurations to eliminate static secrets in favor of **Azure Managed Identities** and **Azure Key Vault**.

---

## Architecture & Threat Model

### Secret Exposure Attack Path
[ Developer Workstation ]
│
├─► Hardcoded Secret in appsettings.json / Dockerfile
│
▼
[ Git Commit / Docker Image Build ]
│
├─► Secret preserved in Git history (.git/logs)
└─► Secret baked into Docker intermediate image layer
│
▼
[ Public Registry / GitHub Leak ] ──► [ Attacker Scrapes Credential ] ──► [ Azure Tenant Compromise ]


### Risk Analysis
- **Git Commit History:** Deleting a credential in a subsequent commit does not remove it from `.git` commit logs. Attackers pull historical commit objects to harvest revoked or active keys.
- **Container Image Metadata:** `ENV` directives in Dockerfiles persist in image metadata (`docker history`). Anyone with pull access to the image registry can extract environment variables.

---

## Implementation & Hands-on Steps

### 1. Source Code Secret Detection (Gitleaks)
Ran automated pattern matching and entropy scanning against repository commit logs:
```bash
gitleaks detect -v
2. Container Layer Inspection (Trivy)
Evaluated container image filesystem layers and metadata for embedded private keys and API keys:

Bash
trivy image --scanners secret --image-config-scanners secret vulnerable-app:v5
3. Automated Prevention via Git Pre-commit Hook
Deployed a client-side Git pre-commit hook in .git/hooks/pre-commit executing gitleaks protect --staged -v.

Added custom .gitleaks.toml rules to target low-entropy environment variable assignments:

Ini, TOML
title = "Custom Cloud Security Lab Rules"

[[rules]]
id = "generic-env-secret"
description = "Detected potential secret assigned in environment file"
regex = '''(?i)(SECRET|KEY|PASSWORD|TOKEN|CONNECTION_STRING)\s*=\s*['"]?[A-Za-z0-9_~\-]{16,}['"]?'''
keywords = ["SECRET", "KEY", "PASSWORD", "TOKEN"]
Verified Evidence
1. Container Layer Secret Finding (Trivy)
Trivy identified an asymmetric private key embedded during the Docker image build phase (COPY id_rsa /app/id_rsa):

Plaintext
HIGH: AsymmetricPrivateKey (private-key)
/app/id_rsa:2-27 (added by 'COPY id_rsa /app/id_rsa # buildkit')
   1    -----BEGIN PRIVATE KEY-----
   2 ┌ ****************************************************************
   28   -----END PRIVATE KEY-----
2. Automated Commit Rejection (Gitleaks Hook)
The pre-commit hook successfully intercepted a staged .env file containing an Azure client secret and blocked the commit:

Plaintext
Finding:     AZURE_CLIENT_SECRET="4a7B~xY9zK_LpQ8mR2vW0sN3tU5vX7yZ1aB3cD5e"
RuleID:      generic-env-secret
File:        leak_test.env

====================================================
[!] ERROR: Gitleaks detected a secret in staged files!
[!] Commit blocked. Remove secrets before committing.
====================================================
Production Security Recommendations & Architectural Fix
Eliminate Static Credentials: Replace Service Principal Client Secrets with Azure System-Assigned or User-Assigned Managed Identities.

Runtime Secret Injection: For workloads requiring static third-party API keys, fetch credentials dynamically at runtime from Azure Key Vault using DefaultAzureCredential() or mount them via Secrets Store CSI Driver.

CI/CD Pipeline Gates: Enforce Gitleaks and Trivy checks inside GitHub Actions / Azure DevOps pipelines to prevent non-compliant images from reaching Azure Container Registry (ACR).
