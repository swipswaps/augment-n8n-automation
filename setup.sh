#!/bin/bash
################################################################################
# Main setup script for Augment Code n8n Automation
# Runs all required scripts in the correct order with comprehensive error handling
# Per USER_EXPECTATIONS_ANALYSIS.txt: "Actually test each command before claiming it works"
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log "Checking system prerequisites..."

    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first:"
        echo "  Ubuntu/Debian: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
        echo "  Fedora/RHEL: sudo dnf install -y docker docker-compose"
        echo "  Then run: sudo usermod -aG docker \$USER"
        echo "  Logout and login again, then re-run this script."
        exit 1
    fi

    # Check if Docker Compose is available
    if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose."
        exit 1
    fi

    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        error "Docker daemon is not running. Please start Docker:"
        echo "  sudo systemctl start docker"
        exit 1
    fi

    # Check if port 5678 is available
    if netstat -tuln 2>/dev/null | grep -q ":5678" || ss -tuln 2>/dev/null | grep -q ":5678"; then
        warning "Port 5678 is already in use. n8n may fail to start."
        echo "  To fix: sudo netstat -tulpn | grep :5678"
        echo "  Then stop the conflicting service."
    fi

    success "All prerequisites met!"
}

echo "===== Augment Code n8n Automation Setup ====="
echo "This script will set up the complete n8n workflow system."
echo "Solving Augment Code extension problems: context loss, silent failures, fragmented testing"
echo ""

# Check prerequisites first
check_prerequisites

# Make all scripts executable
chmod +x scripts/*.sh

# Step 1: Install n8n with Docker
echo ""
log "[STEP 1] Installing n8n with Docker..."
if ./scripts/install_n8n_docker.sh; then
    success "n8n Docker installation completed"
else
    error "Failed to install n8n with Docker"
    exit 1
fi

# Wait for n8n to start
log "Waiting for n8n to start..."
sleep 10

# Step 2: Import the workflow
echo ""
log "[STEP 2] Importing workflow..."
if ./scripts/import_workflow.sh workflows/augment_github_workflow.json; then
    success "Workflow import completed"
else
    error "Failed to import workflow"
    exit 1
fi

# Step 3: Verify installation
echo ""
log "[STEP 3] Verifying installation..."
if ./scripts/verify_installation.sh; then
    success "Installation verification completed"
else
    warning "Installation verification had issues (check logs above)"
fi

echo ""
echo "===== Setup Complete ====="
success "n8n is now running at: http://localhost:5678"
echo "Username: admin"
echo "Password: strongpassword"
echo ""
echo "🎯 Next steps:"
echo "1. Open http://localhost:5678 in your browser"
echo "2. Configure GitHub credentials in n8n (Credentials → Add Credential → GitHub API)"
echo "3. Update workflow with your project paths"
echo "4. Test the workflow execution"
echo ""
echo "📚 For detailed guidance, see:"
echo "  - docs/TECHNICAL_GUIDE.md"
echo "  - docs/LOCAL_TESTING_GUIDE.md"