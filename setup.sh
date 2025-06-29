#!/bin/bash
# Main setup script for Augment Code n8n Automation
# Runs all required scripts in the correct order

set -euo pipefail
IFS=$'\n\t'

echo "===== Augment Code n8n Automation Setup ====="
echo "This script will set up the complete n8n workflow system."

# Make all scripts executable
chmod +x scripts/*.sh

# Install n8n with Docker
echo "[STEP 1] Installing n8n with Docker..."
./scripts/install_n8n_docker.sh

# Wait for n8n to start
echo "[INFO] Waiting for n8n to start..."
sleep 10

# Import workflow
echo "[STEP 2] Importing workflow..."
./scripts/import_workflow.sh workflows/augment_github_workflow.json

# Verify installation
echo "[STEP 3] Verifying installation..."
./scripts/verify_installation.sh

echo "===== Setup Complete ====="
echo "To upload this project to GitHub, run:"
echo "./scripts/upload_to_github.sh"