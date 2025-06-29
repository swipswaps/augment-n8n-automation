#!/bin/bash
# n8n workflow import script
# Imports workflow JSON into running n8n instance via REST API

set -euo pipefail
IFS=$'\n\t'

# Validate input
if [ $# -ne 1 ]; then
    echo "[ERROR] Usage: $0 <workflow_json_file>"
    exit 1
fi

WORKFLOW_JSON="$1"

if [ ! -f "$WORKFLOW_JSON" ]; then
    echo "[ERROR] Workflow JSON file not found: $WORKFLOW_JSON"
    exit 1
fi

# Check if n8n is running
echo "[INFO] Checking if n8n is running..."
if ! curl -s http://localhost:5678/healthz &> /dev/null; then
    echo "[ERROR] n8n is not running. Start it with: docker compose up -d"
    exit 1
fi

# Import workflow via n8n API
echo "[INFO] Importing workflow into n8n..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    http://localhost:5678/rest/workflows \
    -H "Content-Type: application/json" \
    -u admin:strongpassword \
    -d @"$WORKFLOW_JSON")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 201 ]; then
    echo "[SUCCESS] Workflow imported successfully."
    WORKFLOW_ID=$(echo "$RESPONSE_BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "[INFO] Workflow ID: $WORKFLOW_ID"
    echo "[INFO] Access the workflow at: http://localhost:5678/workflow/$WORKFLOW_ID"
else
    echo "[ERROR] Failed to import workflow. HTTP Code: $HTTP_CODE"
    echo "[ERROR] Response: $RESPONSE_BODY"
    exit 1
fi