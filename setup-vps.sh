#!/bin/bash

# Clawdbot VPS Setup Script
# Run this on your VPS after cloning the repository

set -e

echo "🚀 Clawdbot VPS Setup Script"
echo "=================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Create data directories
echo "📁 Creating persistent directories..."
mkdir -p ./data/config
mkdir -p ./data/workspace
mkdir -p ./data/skills

# Set ownership for container user (uid 1000)
echo "🔐 Setting permissions..."
chown -R 1000:1000 ./data/

# Generate random tokens if .env doesn't exist
if [ ! -f .env ]; then
    echo "🔑 Generating secure tokens..."
    cat > .env <<EOF
# Clawdbot Gateway Environment Variables
# Generated on $(date)

# Gateway Configuration
CLAWDBOT_GATEWAY_TOKEN=$(openssl rand -hex 32)
CLAWDBOT_GATEWAY_BIND=lan
CLAWDBOT_GATEWAY_PORT=18789

# Persistence Paths
CLAWDBOT_CONFIG_DIR=./data/config
CLAWDBOT_WORKSPACE_DIR=./data/workspace

# External Tool Secrets
GOG_KEYRING_PASSWORD=$(openssl rand -hex 32)
XDG_CONFIG_HOME=/home/node/.clawdbot
EOF

    echo "✅ Created .env with secure tokens"
    echo "📝 Please review and add additional credentials to .env"
else
    echo "⚠️  .env already exists, skipping token generation"
fi

# Generate .gitkeep files
touch ./data/config/.gitkeep
touch ./data/workspace/.gitkeep
touch ./data/skills/.gitkeep

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env and add your provider credentials"
echo "2. Build and start: docker compose build && docker compose up -d"
echo "3. View logs: docker compose logs -f clawdbot-gateway"
echo ""
echo "For detailed deployment guide, see DEPLOYMENT.md"
