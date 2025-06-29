# Technical Guide: Augment Code n8n Automation

## System Architecture

This automation system consists of:

1. **n8n Instance**: Running in Docker with persistent storage
2. **Workflow Definition**: JSON configuration for the automation pipeline
3. **Support Scripts**: For installation, import, and verification

## Components Explained

### Docker Setup

The system uses the official n8n Docker image with:

- Persistent volume mapping to preserve workflows and credentials
- Basic authentication for security
- Health checks to ensure the service is running correctly
- Proper user permissions (UID 1000) to avoid permission issues

### Workflow Logic

The workflow addresses the identified Augment Code issues through:

1. **Context Preservation**: Stores project path, git info in a Function node
2. **File Validation**: Checks if required scripts exist before proceeding
3. **Repository Management**: Checks if GitHub repo exists, creates if needed
4. **Git Operations**: Handles add, commit, push in a single operation
5. **Testing Integration**: Runs tests after pushing changes
6. **Notifications**: Sends detailed status reports via Telegram

### Error Handling

The workflow implements robust error handling:

- Each step checks for success before proceeding
- Conditional branches handle different scenarios
- Detailed error messages are included in notifications
- Exit codes are used to signal success/failure

## Security Considerations

- Basic authentication is enabled for n8n
- Credentials are stored in n8n's encrypted storage
- .gitignore excludes sensitive data from repository

## Extending the System

To add new workflows:

1. Create a new JSON file in the `workflows/` directory
2. Import it using the `import_workflow.sh` script
3. Configure any required credentials in the n8n UI

## Troubleshooting

Common issues and solutions:

- **n8n not starting**: Check Docker logs with `docker compose logs n8n`
- **Workflow import failing**: Verify n8n is running and credentials are correct
- **Git operations failing**: Ensure SSH keys or credentials are properly set up
- **Telegram notifications not working**: Verify bot token and chat ID are correct