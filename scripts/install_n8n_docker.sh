#!/bin/bash
# n8n Docker installation script
# Sets up n8n with Docker and configures persistent storage

set -euo pipefail
IFS=$'\n\t'

echo "[INFO] Setting up n8n with Docker..."

# Create data directory for persistence
mkdir -p ~/augment-n8n-automation/data
cd ~/augment-n8n-automation

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: "3.8"

services:
  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=strongpassword
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
    volumes:
      - ./data:/home/node/.n8n
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 10s
      retries: 5
EOF

# Set correct permissions for data directory
echo "[INFO] Setting correct permissions for data directory..."
sudo chown -R 1000:1000 ./data

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker not found. Please install Docker first."
    echo "Run: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo "[ERROR] Docker Compose not found. Please install Docker Compose first."
    exit 1
fi

# Start n8n with Docker Compose
echo "[INFO] Starting n8n with Docker Compose..."
docker compose up -d

# Verify n8n is running
echo "[INFO] Verifying n8n is running..."
sleep 10
if curl -s http://localhost:5678/healthz &> /dev/null; then
    echo "[SUCCESS] n8n is running at http://localhost:5678"
    echo "Username: admin"
    echo "Password: strongpassword"
else
    echo "[ERROR] n8n failed to start properly. Check Docker logs:"
    echo "docker compose logs n8n"
fi

echo "[DONE] n8n setup complete."