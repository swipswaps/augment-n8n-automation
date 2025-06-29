#!/bin/bash
# Verification script for n8n workflow setup
# Tests all components to ensure they're working correctly

set -euo pipefail
IFS=$'\n\t'

echo "[INFO] Verifying n8n workflow installation..."

# Check if Docker is running
echo "[TEST] Checking if Docker is running..."
if ! docker info &>/dev/null; then
    echo "[ERROR] Docker is not running. Please start Docker."
    exit 1
fi
echo "[PASS] Docker is running."

# Check if n8n container is running
echo "[TEST] Checking if n8n container is running..."
if ! docker ps | grep -q n8n; then
    echo "[ERROR] n8n container is not running."
    echo "Run: cd ~/augment-n8n-automation && docker compose up -d"
    exit 1
fi
echo "[PASS] n8n container is running."

# Check if n8n API is accessible
echo "[TEST] Checking if n8n API is accessible..."
if ! curl -s -u admin:strongpassword http://localhost:5678/rest/workflows &>/dev/null; then
    echo "[ERROR] Cannot access n8n API. Check if n8n is running correctly."
    exit 1
fi
echo "[PASS] n8n API is accessible."

# Check if workflow JSON exists
echo "[TEST] Checking if workflow JSON exists..."
if [ ! -f ~/augment-n8n-automation/workflows/augment_github_workflow.json ]; then
    echo "[ERROR] Workflow JSON not found."
    exit 1
fi
echo "[PASS] Workflow JSON exists."

# Check if all scripts are executable
echo "[TEST] Checking if all scripts are executable..."
for script in ~/augment-n8n-automation/scripts/*.sh; do
    if [ ! -x "$script" ]; then
        echo "[ERROR] Script $script is not executable."
        echo "Run: chmod +x $script"
        exit 1
    fi
done
echo "[PASS] All scripts are executable."

echo "[SUCCESS] All verification tests passed!"
echo "[INFO] Your n8n workflow automation system is correctly installed and configured."
echo "[INFO] To import the workflow, run: ~/augment-n8n-automation/scripts/import_workflow.sh ~/augment-n8n-automation/workflows/augment_github_workflow.json"