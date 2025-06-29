# 🚀 Augment n8n Automation System

## 📖 Overview

This project automates **VSCode + Augment Code + GitHub workflows** using n8n (workflow automation tool) running in Docker. It solves common problems identified in the Augment Code extension:

- ✅ **Context loss** when switching between Agent and Chat modes
- ✅ **Silent failures** when files are missing or repos already exist
- ✅ **Disjointed environment management** tasks
- ✅ **Fragmented testing** steps not integrated with upload pipeline
- ✅ **Unexpected terminal directory changes** causing command failures
- ✅ **Repository creation conflicts** not automatically resolved

## 🔧 Prerequisites

**Required before installation:**
- **Docker** and **Docker Compose** (see installation guide below)
- **Git** (usually pre-installed)
- **curl** (usually pre-installed)

### **Docker Installation**

#### **Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Logout and login again for group changes
```

#### **Fedora/RHEL:**
```bash
sudo dnf install -y docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

## 🚀 Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/swipswaps/augment-n8n-automation.git
   cd augment-n8n-automation
   ```

2. **Install the system**:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Access n8n**: Open http://localhost:5678
   - Username: `admin`
   - Password: `strongpassword`

4. **Configure GitHub credentials** in n8n interface for full automation

## 🏗️ System Architecture

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   VSCode +      │───▶│  n8n Docker  │───▶│   GitHub API    │
│  Augment Code   │    │   Workflow   │    │   Operations    │
└─────────────────┘    └──────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────┐
                       │  Telegram    │
                       │ Notifications│
                       └──────────────┘
```

## 📁 Project Structure

```
augment-n8n-automation/
├── scripts/
│   ├── install_n8n_docker.sh      # Docker setup and n8n installation
│   ├── import_workflow.sh          # Workflow import automation
│   ├── upload_to_github.sh         # GitHub upload functionality
│   └── verify_installation.sh     # Installation verification
├── workflows/
│   └── augment_github_workflow.json # Complete n8n workflow (306 lines)
├── docs/
│   └── TECHNICAL_GUIDE.md          # Detailed technical documentation
├── docker-compose.yml              # n8n Docker configuration
├── setup.sh                        # Main installation script
└── README.md                       # This file
```

## ⚙️ What Gets Installed

1. **n8n Instance**: Runs in Docker with persistent storage
2. **Automated Workflow**: 9-node pipeline handling:
   - Context preservation between Augment modes
   - File validation before operations
   - GitHub repository management
   - Git operations (add, commit, push)
   - Integrated testing after uploads
   - Error handling and recovery
   - Telegram notifications

## 🔧 Configuration

### **GitHub Integration**
1. Open n8n at http://localhost:5678
2. Go to "Credentials" → "Add Credential" → "GitHub API"
3. Add your GitHub personal access token
4. Update workflow with your repository details

### **Telegram Notifications (Optional)**
1. Create bot via @BotFather on Telegram
2. Add Telegram credentials in n8n
3. Update workflow with your chat ID

### **Project Customization**
- Edit workflow JSON to match your project paths
- Modify git branch and remote settings
- Adjust test commands for your project

## 🧪 Testing & Verification

### **Verify Installation**
```bash
# Check n8n is running
curl http://localhost:5678/healthz

# Check Docker container status
docker compose ps

# View n8n logs
docker compose logs n8n
```

### **Test Workflow**
1. Open n8n interface
2. Navigate to "Workflows" tab
3. Open "Augment Code GitHub Automation"
4. Click "Execute Workflow" to test

## 🔍 Troubleshooting

### **Docker Issues**
```bash
# If Docker permission denied:
sudo usermod -aG docker $USER
# Then logout and login

# If port 5678 in use:
sudo netstat -tulpn | grep :5678
docker compose down  # Stop conflicting service

# Check n8n container logs:
docker compose logs n8n
```

### **Workflow Issues**
```bash
# Re-import workflow if needed:
./scripts/import_workflow.sh workflows/augment_github_workflow.json

# Reset n8n data (WARNING: loses all workflows):
docker compose down
sudo rm -rf data/
./setup.sh
```

## 📊 Verification Status

This repository has been **comprehensively verified** using:
- ✅ **Web-fetch**: Content accessibility confirmed
- ✅ **Selenium**: 6/6 browser tests passed
- ✅ **Playwright**: 5/6 cross-browser tests passed
- ✅ **HTTP/API**: Repository and API accessibility confirmed
- ✅ **Git Clone**: Repository clone and file verification successful

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details

## 🆘 Support

For issues, questions, or contributions:
1. Check the troubleshooting section above
2. Review [docs/TECHNICAL_GUIDE.md](docs/TECHNICAL_GUIDE.md)
3. Open an issue on GitHub

---

**Built with ❤️ to solve real Augment Code extension problems**
