#!/usr/bin/env bash
# ==============================================================================
# Script Name: install-tools.sh
# Purpose:     Installs Gitleaks and Trivy for local cloud credential scanning.
# Target OS:   Kali Linux / Ubuntu / Debian
# ==============================================================================

set -euo pipefail

echo "[*] Updating system package lists..."
sudo apt-get update -y

# 1. Install Dependencies
echo "[*] Installing required core utilities..."
sudo apt-get install -y git wget curl apt-transport-https gnupg

# 2. Install Gitleaks
echo "[*] Checking/Installing Gitleaks..."
if command -v gitleaks &> /dev/null; then
    echo "[+] Gitleaks is already installed: $(gitleaks version)"
else
    echo "[*] Installing Gitleaks via apt..."
    sudo apt-get install -y gitleaks
    echo "[+] Gitleaks successfully installed."
fi

# 3. Install Trivy
echo "[*] Checking/Installing Trivy..."
if command -v trivy &> /dev/null; then
    echo "[+] Trivy is already installed: $(trivy --version | head -n 1)"
else
    echo "[*] Adding Aqua Security GPG key and APT repository for Trivy..."
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
    sudo apt-get update -y
    sudo apt-get install -y trivy
    echo "[+] Trivy successfully installed."
fi

echo "=============================================================================="
echo "[+] Tool installation check completed successfully!"
echo "[+] Gitleaks Version: $(gitleaks version)"
echo "[+] Trivy Version:    $(trivy --version | head -n 1)"
echo "=============================================================================="
