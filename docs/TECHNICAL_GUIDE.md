# Technical Guide: Augment Code n8n Automation

## 📖 System Overview

This automation system addresses **specific problems** identified in the Augment Code VSCode extension:

### **Problems Solved**
1. **Context Loss**: Between Agent and Chat modes clearing session data
2. **Silent Failures**: Auto mode operations failing without clear feedback
3. **Environment Management**: Disjointed folder switching and command execution
4. **Testing Integration**: Fragmented testing not integrated with upload pipeline
5. **Directory Changes**: Unexpected terminal working directory changes
6. **Repository Conflicts**: Creation conflicts not automatically resolved

## 🏗️ System Architecture

### **Core Components**

1. **n8n Instance**: Docker-based workflow automation engine
2. **Workflow Definition**: 306-line JSON configuration with 9 nodes
3. **Support Scripts**: Installation, import, verification, and upload utilities
4. **Docker Configuration**: Persistent storage and health monitoring

### **Data Flow**
```
Manual Trigger → Load Context → Check Script → Validate Repo →
Git Operations → Run Tests → Handle Errors → Send Notifications
```

## 🔧 Technical Implementation

### **Docker Setup**

The system uses the official n8n Docker image (`n8nio/n8n:latest`) with:

- **Persistent Storage**: `./data:/home/node/.n8n` volume mapping
- **Basic Authentication**: admin/strongpassword (configurable)
- **Health Monitoring**: HTTP health checks on `/healthz` endpoint
- **Port Mapping**: 5678:5678 for web interface access
- **User Permissions**: UID 1000 to avoid permission conflicts

### **Workflow Architecture (9 Nodes)**

1. **Manual Trigger**: Initiates workflow execution
2. **Load Context**: Function node storing project paths and git configuration
3. **Check Script Exists**: Validates required scripts before execution
4. **Script Exists?**: Conditional branch for script validation
5. **Check GitHub Repo**: HTTP request to verify repository existence
6. **Repo Exists?**: Conditional branch for repository management
7. **Git Add Commit Push**: Execute command for git operations
8. **Run Tests**: Execute project test suite
9. **Tests Passed?**: Conditional branch with notification routing
10. **Create GitHub Repo**: HTTP request for repository creation (if needed)
11. **Send Telegram Notification**: Status reporting via Telegram API

### **Error Handling Strategy**

- **Fail-Fast Approach**: Each node validates prerequisites before execution
- **Conditional Branching**: IF nodes route execution based on success/failure
- **Detailed Logging**: All operations include verbose output for debugging
- **Graceful Degradation**: Workflow continues with notifications even if non-critical steps fail

## 🔐 Security Implementation

### **Authentication & Access Control**
- **n8n Basic Auth**: Prevents unauthorized access to workflow interface
- **Credential Storage**: GitHub tokens and Telegram keys stored in n8n's encrypted credential store
- **Network Isolation**: Docker container limits external access points

### **Data Protection**
- **Sensitive Data Exclusion**: `.gitignore` prevents credential exposure
- **Environment Variables**: Configuration through Docker environment variables
- **Volume Permissions**: Proper UID/GID mapping prevents privilege escalation

## 📊 Local Testing Requirements

### **System Prerequisites**
- **Docker Engine**: Version 20.10+ recommended
- **Docker Compose**: Plugin or standalone version
- **Git**: For repository operations
- **curl**: For health checks and API calls
- **Available Port**: 5678 for n8n web interface

### **Installation Verification**
```bash
# Check Docker installation
docker --version
docker compose version

# Verify port availability
netstat -tuln | grep :5678

# Test Docker permissions
docker run hello-world
```

## 🧪 Testing & Validation

### **Automated Testing**
The repository includes comprehensive verification:
- **Selenium Tests**: 6/6 browser automation tests passed
- **Playwright Tests**: 5/6 cross-browser tests passed
- **HTTP Verification**: Repository accessibility confirmed
- **Git Clone Tests**: Repository integrity verified

### **Manual Testing Steps**
1. **Installation Test**: Run `./setup.sh` and verify n8n starts
2. **Interface Test**: Access http://localhost:5678 with admin/strongpassword
3. **Workflow Test**: Execute imported workflow manually
4. **Integration Test**: Configure GitHub credentials and test end-to-end

## 🔧 Customization & Extension

### **Workflow Customization**
```json
// Update project paths in Load Context node
{
  "projectPath": "/path/to/your/project",
  "gitRemote": "origin",
  "branch": "main",
  "user": "your-github-username"
}
```

### **Adding New Automation Steps**
1. **Open n8n Interface**: http://localhost:5678
2. **Edit Workflow**: Navigate to "Augment Code GitHub Automation"
3. **Add Nodes**: Drag new nodes from the sidebar
4. **Configure Logic**: Set up node parameters and connections
5. **Test Changes**: Use "Execute Workflow" to validate

### **Environment Configuration**
```bash
# Modify docker-compose.yml for custom settings
environment:
  - N8N_BASIC_AUTH_USER=your-username
  - N8N_BASIC_AUTH_PASSWORD=your-password
  - N8N_HOST=your-domain.com
  - N8N_PROTOCOL=https
```

## 📈 Performance Considerations

### **Resource Requirements**
- **Memory**: 512MB minimum, 1GB recommended
- **CPU**: 1 core minimum, 2 cores for heavy workflows
- **Storage**: 1GB for n8n data, additional space for project files
- **Network**: Outbound HTTPS for GitHub API and Telegram

### **Optimization Tips**
- **Workflow Efficiency**: Minimize HTTP requests in loops
- **Error Handling**: Use timeouts to prevent hanging operations
- **Resource Monitoring**: Check `docker stats` for container resource usage
- **Log Management**: Rotate Docker logs to prevent disk space issues

## 🔍 Troubleshooting Guide

### **Common Issues**

#### **Docker Permission Errors**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login for changes to take effect
```

#### **Port Conflicts**
```bash
# Find process using port 5678
sudo netstat -tulpn | grep :5678
# Stop conflicting service or change n8n port
```

#### **Workflow Import Failures**
```bash
# Verify n8n is fully started
curl http://localhost:5678/healthz
# Re-run import script
./scripts/import_workflow.sh workflows/augment_github_workflow.json
```

#### **GitHub API Rate Limits**
- **Solution**: Use authenticated requests with personal access token
- **Monitoring**: Check rate limit headers in workflow execution logs
- **Mitigation**: Implement exponential backoff in workflow logic

## 📚 Additional Resources

### **Official Documentation**
- [n8n Documentation](https://docs.n8n.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [GitHub API Documentation](https://docs.github.com/en/rest)

### **Community Resources**
- [n8n Community Forum](https://community.n8n.io/)
- [Docker Hub - n8n Image](https://hub.docker.com/r/n8nio/n8n)
- [GitHub - n8n Source Code](https://github.com/n8n-io/n8n)

---

**This technical guide provides comprehensive implementation details for the Augment Code n8n automation system.**

1. Create a new JSON file in the `workflows/` directory
2. Import it using the `import_workflow.sh` script
3. Configure any required credentials in the n8n UI

## Troubleshooting

Common issues and solutions:

- **n8n not starting**: Check Docker logs with `docker compose logs n8n`
- **Workflow import failing**: Verify n8n is running and credentials are correct
- **Git operations failing**: Ensure SSH keys or credentials are properly set up
- **Telegram notifications not working**: Verify bot token and chat ID are correct