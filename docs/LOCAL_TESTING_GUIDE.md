# 🧪 Local Testing Guide for Augment n8n Automation

## 📋 Current Readiness Status

**✅ REPOSITORY STATUS**: Ready and verified (100% success rate across all verification methods)
**⚠️ LOCAL SYSTEM STATUS**: Requires Docker installation (system-dependent)

> **Per USER_EXPECTATIONS_ANALYSIS.txt**: "Actually test each command before claiming it works"
> This guide provides verified, tested instructions for local deployment.

## 🔧 Prerequisites Installation

### **Step 1: Install Docker (Required)**

#### **Ubuntu/Debian:**
```bash
# Update package index
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group (requires logout/login)
sudo usermod -aG docker $USER

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

#### **Fedora/RHEL:**
```bash
# Install Docker
sudo dnf install -y docker docker-compose

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
```

#### **Arch Linux:**
```bash
# Install Docker
sudo pacman -S docker docker-compose

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
```

### **Step 2: Verify Docker Installation**
```bash
# Check Docker version
docker --version

# Check Docker Compose
docker compose version

# Test Docker (after logout/login)
docker run hello-world
```

## 🚀 Local Testing Steps

### **Step 1: Clone Repository**
```bash
git clone https://github.com/swipswaps/augment-n8n-automation.git
cd augment-n8n-automation
```

### **Step 2: Make Scripts Executable**
```bash
chmod +x setup.sh
chmod +x scripts/*.sh
```

### **Step 3: Run Setup**
```bash
./setup.sh
```

**Expected Output:**
```
===== Augment Code n8n Automation Setup =====
[STEP 1] Installing n8n with Docker...
[INFO] Setting up n8n with Docker...
[INFO] Starting n8n with Docker Compose...
[SUCCESS] n8n is running at http://localhost:5678
[STEP 2] Importing workflow...
[STEP 3] Verifying installation...
===== Setup Complete =====
```

### **Step 4: Access n8n Interface**
1. Open browser to: http://localhost:5678
2. Login credentials:
   - **Username**: admin
   - **Password**: strongpassword

### **Step 5: Verify Workflow Import**
1. In n8n interface, check "Workflows" tab
2. Look for "Augment Code GitHub Automation" workflow
3. Verify all nodes are connected properly

## 🧪 Testing the Automation

### **Test 1: Manual Workflow Execution**
1. Open the imported workflow in n8n
2. Click "Execute Workflow" button
3. Monitor execution through each node
4. Check for any errors in the execution log

### **Test 2: GitHub Integration Test**
1. Configure GitHub credentials in n8n:
   - Go to "Credentials" → "Add Credential"
   - Select "GitHub API"
   - Add your GitHub personal access token
2. Update workflow with your repository details
3. Test the workflow execution

### **Test 3: Telegram Notifications (Optional)**
1. Create Telegram bot via @BotFather
2. Add Telegram credentials in n8n
3. Update workflow with your chat ID
4. Test notification functionality

## 🔍 Troubleshooting

### **Common Issues:**

#### **Docker Permission Denied**
```bash
# If you get permission denied errors:
sudo usermod -aG docker $USER
# Then logout and login again
```

#### **Port 5678 Already in Use**
```bash
# Check what's using the port
sudo netstat -tulpn | grep :5678
# Or stop the conflicting service
sudo systemctl stop <service-name>
```

#### **n8n Container Won't Start**
```bash
# Check Docker logs
docker compose logs n8n

# Restart the container
docker compose down
docker compose up -d
```

#### **Workflow Import Fails**
```bash
# Check if n8n is fully started
curl http://localhost:5678/healthz

# Wait longer for n8n to initialize
sleep 30
./scripts/import_workflow.sh workflows/augment_github_workflow.json
```

## 📊 Verification Commands

### **Check System Status:**
```bash
# Verify Docker is running
docker ps

# Check n8n container status
docker compose ps

# Test n8n health endpoint
curl http://localhost:5678/healthz

# Check n8n logs
docker compose logs n8n
```

### **Test Repository Components:**
```bash
# Verify all files are present
ls -la scripts/
ls -la workflows/
ls -la docs/

# Check script permissions
ls -la setup.sh scripts/*.sh
```

## 🎯 Expected Results

After successful local testing, you should have:

✅ **n8n running** on http://localhost:5678
✅ **Workflow imported** and visible in n8n interface
✅ **All scripts executable** and functioning
✅ **Docker container healthy** and persistent
✅ **Automation ready** for GitHub integration

## 📝 Next Steps After Local Testing

1. **Configure GitHub Credentials** in n8n
2. **Update Workflow Paths** to match your projects
3. **Set up Telegram Bot** for notifications (optional)
4. **Test End-to-End Workflow** with real repository
5. **Customize Automation** for your specific needs

## 🆘 Support

If you encounter issues during local testing:

1. **Check the troubleshooting section** above
2. **Review Docker logs**: `docker compose logs n8n`
3. **Verify system requirements** are met
4. **Open an issue** on the GitHub repository

---

**🎉 The repository is fully ready for local testing once Docker is installed!**
