#!/bin/bash
# GitHub upload script using folder2github
# Uploads the entire n8n workflow project to GitHub

set -euo pipefail
IFS=$'\n\t'

# Configuration
REPO_NAME="augment-n8n-automation"
PROJECT_DIR="$HOME/augment-n8n-automation"
FOLDER2GITHUB_DIR="../folder2github"

# Validate folder2github exists
if [ ! -d "$FOLDER2GITHUB_DIR" ]; then
    echo "[ERROR] folder2github directory not found at $FOLDER2GITHUB_DIR"
    exit 1
fi

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "[ERROR] Project directory not found at $PROJECT_DIR"
    exit 1
fi

# Make scripts executable
echo "[INFO] Making scripts executable..."
chmod +x "$PROJECT_DIR/scripts/"*.sh

# Create .gitignore
echo "[INFO] Creating .gitignore..."
cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# n8n data directory
data/

# Credentials
.env

# Logs
*.log

# OS specific files
.DS_Store
Thumbs.db
EOF

# Use folder2github to upload
echo "[INFO] Uploading to GitHub using folder2github..."
cd "$FOLDER2GITHUB_DIR"
./folder2github.sh "$PROJECT_DIR" "$REPO_NAME"

echo "[DONE] Project uploaded to GitHub as $REPO_NAME"
echo "[INFO] Repository URL: https://github.com/$(git config --get user.name)/$REPO_NAME"