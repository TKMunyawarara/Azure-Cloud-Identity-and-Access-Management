#!/usr/bin/env bash
# ==============================================================================
# Script Name: setup-pre-commit.sh
# Purpose:     Deploys an automated Gitleaks pre-commit hook in .git/hooks/
# Target OS:   POSIX-compliant shell (Linux/macOS)
# ==============================================================================

set -euo pipefail

# Ensure the user is inside a Git repository
if [ ! -d ".git" ]; then
    echo "[!] ERROR: Current directory is not a Git repository root."
    echo "[!] Run 'git init' or navigate to the repository root first."
    exit 1
fi

# Ensure Gitleaks binary is installed
if ! command -v gitleaks &> /dev/null; then
    echo "[!] ERROR: Gitleaks binary not found in PATH."
    echo "[!] Please run 'scripts/install-tools.sh' first."
    exit 1
fi

HOOK_PATH=".git/hooks/pre-commit"

echo "[*] Writing pre-commit hook to ${HOOK_PATH}..."

cat << 'EOF' > "${HOOK_PATH}"
#!/usr/bin/env bash
# Automatically generated pre-commit hook by setup-pre-commit.sh

echo "[*] Executing Gitleaks pre-commit secret check..."

# Run Gitleaks against staged files only
gitleaks protect --staged -v

# Capture Gitleaks exit status
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "===================================================="
    echo "[!] COMMIT REJECTED: Gitleaks detected staged secrets!"
    echo "[!] Remove the secret or unstage the file to proceed."
    echo "===================================================="
    exit 1
fi

echo "[+] Secret scan clean. Commit proceeding..."
exit 0
EOF

# Grant executable permission
chmod +x "${HOOK_PATH}"

echo "=============================================================================="
echo "[+] Pre-commit hook successfully configured and made executable!"
echo "[+] Target File: ${HOOK_PATH}"
echo "[+] Test execution by running: git commit -m 'Test'"
echo "=============================================================================="
