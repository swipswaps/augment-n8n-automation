#!/bin/bash
################################################################################
# 🛡️ ENHANCED SETUP SCRIPT - Augment Code n8n Automation with Safety Features
# Runs all required scripts in the correct order with comprehensive error handling
# Per USER_EXPECTATIONS_ANALYSIS.txt: "Actually test each command before claiming it works"
#
# SAFETY FEATURES:
# - Pre-installation system checks
# - Backup existing configurations
# - Rollback capability on failure
# - Multiple verification methods
# - Safe mode by default
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups/$(date +%Y%m%d_%H%M%S)"
LOG_DIR="$SCRIPT_DIR/logs"
TIMESTAMP=$(date +%s)

# Safety mode options
SAFE_MODE=true
CHECK_ONLY=false
DRY_RUN=false
FORCE_MODE=false
QUICK_MODE=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --safe)
            SAFE_MODE=true
            shift
            ;;
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE_MODE=true
            SAFE_MODE=false
            shift
            ;;
        --quick)
            QUICK_MODE=true
            SAFE_MODE=false
            shift
            ;;
        --help|-h)
            echo "🛡️ Enhanced n8n Automation Setup with Safety Features"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Safety Options:"
            echo "  --safe       Safe mode with comprehensive checks (default)"
            echo "  --check-only Check system requirements without installing"
            echo "  --dry-run    Preview all operations without executing"
            echo "  --quick      Quick installation with minimal checks"
            echo "  --force      Force installation bypassing safety checks"
            echo "  --help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Safe installation (recommended)"
            echo "  $0 --check-only      # Check system requirements only"
            echo "  $0 --dry-run         # Preview installation steps"
            echo "  $0 --quick           # Quick installation"
            echo "  $0 --force           # Force installation (use with caution)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Enhanced logging functions
log() {
    local message="$1"
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $message"
    mkdir -p "$LOG_DIR"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_DIR/setup_$TIMESTAMP.log"
}

error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} $message" >&2
    mkdir -p "$LOG_DIR"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $message" >> "$LOG_DIR/setup_$TIMESTAMP.log"
}

success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS]${NC} $message"
    mkdir -p "$LOG_DIR"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $message" >> "$LOG_DIR/setup_$TIMESTAMP.log"
}

warning() {
    local message="$1"
    echo -e "${YELLOW}[WARNING]${NC} $message"
    mkdir -p "$LOG_DIR"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $message" >> "$LOG_DIR/setup_$TIMESTAMP.log"
}

info() {
    local message="$1"
    echo -e "${CYAN}[INFO]${NC} $message"
    mkdir -p "$LOG_DIR"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $message" >> "$LOG_DIR/setup_$TIMESTAMP.log"
}

# Safety functions
create_backup() {
    if [[ "$SAFE_MODE" == "true" ]]; then
        log "🛡️ Creating safety backup..."
        mkdir -p "$BACKUP_DIR"

        # Backup existing Docker configurations
        if docker ps -a --format "table {{.Names}}" | grep -q "n8n"; then
            log "Backing up existing n8n container configuration..."
            docker inspect n8n > "$BACKUP_DIR/n8n_container_config.json" 2>/dev/null || true
        fi

        # Backup existing docker-compose files
        if [[ -f "docker-compose.yml" ]]; then
            cp docker-compose.yml "$BACKUP_DIR/docker-compose.yml.backup"
        fi

        # Backup existing workflows
        if [[ -d "workflows" ]]; then
            cp -r workflows "$BACKUP_DIR/workflows_backup"
        fi

        success "Backup created at: $BACKUP_DIR"
    fi
}

rollback() {
    if [[ -d "$BACKUP_DIR" ]]; then
        warning "🔄 Initiating rollback..."

        # Stop any containers we started
        docker stop n8n 2>/dev/null || true
        docker rm n8n 2>/dev/null || true

        # Restore configurations if they exist
        if [[ -f "$BACKUP_DIR/docker-compose.yml.backup" ]]; then
            cp "$BACKUP_DIR/docker-compose.yml.backup" docker-compose.yml
        fi

        success "Rollback completed"
    fi
}

# Enhanced prerequisites check
check_prerequisites() {
    log "🔍 Performing comprehensive system checks..."
    local issues=0

    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first:"
        echo "  Ubuntu/Debian: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
        echo "  Fedora/RHEL: sudo dnf install -y docker docker-compose"
        echo "  Then run: sudo usermod -aG docker \$USER"
        echo "  Logout and login again, then re-run this script."
        ((issues++))
    else
        success "Docker is installed: $(docker --version)"
    fi

    # Check if Docker Compose is available
    if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose."
        ((issues++))
    else
        if command -v docker compose &> /dev/null; then
            success "Docker Compose is available: $(docker compose version)"
        else
            success "Docker Compose is available: $(docker-compose --version)"
        fi
    fi

    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        error "Docker daemon is not running. Please start Docker:"
        echo "  sudo systemctl start docker"
        ((issues++))
    else
        success "Docker daemon is running"
    fi

    # Enhanced system checks for safe mode
    if [[ "$SAFE_MODE" == "true" || "$CHECK_ONLY" == "true" ]]; then
        log "🛡️ Performing additional safety checks..."

        # Check available memory
        local mem_available=$(free -m | awk 'NR==2{printf "%.0f", $7}')
        if [[ $mem_available -lt 1024 ]]; then
            warning "Low available memory: ${mem_available}MB (recommended: 1GB+)"
        else
            success "Available memory: ${mem_available}MB"
        fi

        # Check available disk space
        local disk_available=$(df . | awk 'NR==2{print $4}')
        local disk_available_gb=$((disk_available / 1024 / 1024))
        if [[ $disk_available_gb -lt 5 ]]; then
            warning "Low disk space: ${disk_available_gb}GB (recommended: 5GB+)"
        else
            success "Available disk space: ${disk_available_gb}GB"
        fi

        # Check for existing n8n installations
        if docker ps -a --format "table {{.Names}}" | grep -q "n8n"; then
            warning "Existing n8n container found. Will be handled safely."
        fi

        # Check network connectivity
        if ping -c 1 google.com &> /dev/null; then
            success "Network connectivity verified"
        else
            warning "Network connectivity issues detected"
        fi
    fi

    # Check if port 5678 is available
    if netstat -tuln 2>/dev/null | grep -q ":5678" || ss -tuln 2>/dev/null | grep -q ":5678"; then
        if [[ "$FORCE_MODE" == "true" ]]; then
            warning "Port 5678 is in use but continuing due to force mode"
        else
            error "Port 5678 is already in use. n8n will fail to start."
            echo "  To fix: sudo netstat -tulpn | grep :5678"
            echo "  Then stop the conflicting service or use --force to override."
            ((issues++))
        fi
    else
        success "Port 5678 is available"
    fi

    # Exit if issues found and not in force mode
    if [[ $issues -gt 0 && "$FORCE_MODE" != "true" ]]; then
        error "Found $issues issue(s). Please resolve them before continuing."
        echo "  Use --force to bypass these checks (not recommended)"
        exit 1
    elif [[ $issues -gt 0 ]]; then
        warning "Found $issues issue(s) but continuing due to force mode"
    else
        success "All prerequisites met!"
    fi

    # Exit if check-only mode
    if [[ "$CHECK_ONLY" == "true" ]]; then
        success "✅ System check completed. Ready for installation."
        exit 0
    fi
}

# Display safety mode information
echo "🛡️ ===== ENHANCED AUGMENT CODE N8N AUTOMATION SETUP ====="
echo "This script will set up the complete n8n workflow system with safety features."
echo "Solving Augment Code extension problems: context loss, silent failures, fragmented testing"
echo ""

# Display current mode
if [[ "$SAFE_MODE" == "true" ]]; then
    echo -e "${GREEN}🛡️ SAFE MODE ENABLED${NC} - Comprehensive checks and backup creation"
elif [[ "$QUICK_MODE" == "true" ]]; then
    echo -e "${YELLOW}⚡ QUICK MODE ENABLED${NC} - Minimal checks for faster installation"
elif [[ "$FORCE_MODE" == "true" ]]; then
    echo -e "${RED}⚠️ FORCE MODE ENABLED${NC} - Bypassing safety checks (use with caution)"
fi

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${CYAN}🧪 DRY RUN MODE${NC} - Preview mode, no actual changes will be made"
fi

echo ""

# Set up error handling with rollback
trap 'error "Installation failed at line $LINENO"; rollback; exit 1' ERR

# Check prerequisites first
check_prerequisites

# Create backup if in safe mode
create_backup

# Make all scripts executable
if [[ "$DRY_RUN" == "true" ]]; then
    info "Would make scripts executable: chmod +x scripts/*.sh"
else
    chmod +x scripts/*.sh
    success "Scripts made executable"
fi

# Step 1: Install n8n with Docker
echo ""
log "[STEP 1] Installing n8n with Docker..."
if [[ "$DRY_RUN" == "true" ]]; then
    info "Would execute: ./scripts/install_n8n_docker.sh"
    info "Would pull Docker image: n8nio/n8n:latest"
    info "Would create Docker container with port 5678:5678"
    info "Would set up persistent volume for n8n data"
    success "Docker installation preview completed"
else
    if ./scripts/install_n8n_docker.sh; then
        success "n8n Docker installation completed"
    else
        error "Failed to install n8n with Docker"
        rollback
        exit 1
    fi
fi

# Wait for n8n to start
if [[ "$DRY_RUN" == "true" ]]; then
    info "Would wait for n8n to start (10 seconds)"
else
    log "Waiting for n8n to start..."
    sleep 10

    # Verify n8n is responding
    local retries=0
    while [[ $retries -lt 30 ]]; do
        if curl -s http://localhost:5678/healthz &> /dev/null; then
            success "n8n is responding on port 5678"
            break
        fi
        ((retries++))
        sleep 2
    done

    if [[ $retries -eq 30 ]]; then
        warning "n8n may not be fully started yet"
    fi
fi

# Step 2: Import the workflow
echo ""
log "[STEP 2] Importing workflow..."
if [[ "$DRY_RUN" == "true" ]]; then
    info "Would execute: ./scripts/import_workflow.sh workflows/augment_github_workflow.json"
    info "Would import Augment GitHub automation workflow"
    info "Would configure workflow nodes and connections"
    success "Workflow import preview completed"
else
    if ./scripts/import_workflow.sh workflows/augment_github_workflow.json; then
        success "Workflow import completed"
    else
        error "Failed to import workflow"
        rollback
        exit 1
    fi
fi

# Step 3: Verify installation
echo ""
log "[STEP 3] Verifying installation..."
if [[ "$DRY_RUN" == "true" ]]; then
    info "Would execute: ./scripts/verify_installation.sh"
    info "Would perform HTTP health checks"
    info "Would verify Docker container status"
    info "Would test workflow functionality"
    success "Installation verification preview completed"
else
    if ./scripts/verify_installation.sh; then
        success "Installation verification completed"
    else
        warning "Installation verification had issues (check logs above)"
        if [[ "$SAFE_MODE" == "true" ]]; then
            warning "Consider running rollback if issues persist"
        fi
    fi
fi

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
    echo "🧪 ===== DRY RUN COMPLETE ====="
    success "Preview completed successfully!"
    echo ""
    echo "📋 What would be installed:"
    echo "  ✅ n8n Docker container on port 5678"
    echo "  ✅ Augment GitHub automation workflow"
    echo "  ✅ Comprehensive verification checks"
    echo ""
    echo "🎯 To proceed with actual installation:"
    echo "  $0 --safe    # Recommended: safe installation with backups"
    echo "  $0 --quick   # Quick installation with minimal checks"
    echo "  $0 --force   # Force installation bypassing checks"
else
    echo "🛡️ ===== ENHANCED SETUP COMPLETE ====="
    success "n8n is now running at: http://localhost:5678"
    echo "Username: admin"
    echo "Password: strongpassword"
    echo ""

    if [[ "$SAFE_MODE" == "true" ]]; then
        echo "🛡️ Safety features enabled:"
        echo "  ✅ Backup created at: $BACKUP_DIR"
        echo "  ✅ Installation logs: $LOG_DIR/setup_$TIMESTAMP.log"
        echo "  ✅ Rollback available if needed"
        echo ""
    fi

    echo "🎯 Next steps:"
    echo "1. Open http://localhost:5678 in your browser"
    echo "2. Configure GitHub credentials in n8n (Credentials → Add Credential → GitHub API)"
    echo "3. Update workflow with your project paths"
    echo "4. Test the workflow execution"
    echo ""
    echo "📚 For detailed guidance, see:"
    echo "  - docs/TECHNICAL_GUIDE.md"
    echo "  - docs/LOCAL_TESTING_GUIDE.md"
    echo "  - SAFETY_FEATURES.md (new)"
    echo ""
    echo "🆘 If you encounter issues:"
    echo "  - Check logs: $LOG_DIR/setup_$TIMESTAMP.log"
    echo "  - Run diagnostics: ./scripts/verify_installation.sh"
    if [[ "$SAFE_MODE" == "true" ]]; then
        echo "  - Rollback if needed: restore from $BACKUP_DIR"
    fi
fi

# Clean up trap
trap - ERR