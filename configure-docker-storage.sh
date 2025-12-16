#!/bin/bash

# Configure Docker to use /mnt for storage
# This allows Docker to use the secondary disk partition for image and container storage
# Useful for GitHub runners where /mnt typically has more available space

set -e

echo "🐳 Configuring Docker storage..."

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
  echo "❌ This script must be run as root or with sudo"
  exit 1
fi

# Create Docker data directory on /mnt
echo "📁 Creating Docker data directory on /mnt..."
mkdir -p /mnt/docker
chown root:root /mnt/docker
chmod 700 /mnt/docker

# Backup existing daemon.json if it exists
if [ -f /etc/docker/daemon.json ]; then
  echo "💾 Backing up existing daemon.json..."
  cp /etc/docker/daemon.json /etc/docker/daemon.json.bak.$(date +%s)
fi

# Create/update daemon.json with data-root pointing to /mnt/docker
echo "⚙️ Updating Docker daemon configuration..."
mkdir -p /etc/docker

# Read existing config or create empty object
if [ -f /etc/docker/daemon.json ]; then
  CONFIG=$(cat /etc/docker/daemon.json)
else
  CONFIG="{}"
fi

# Update data-root (using jq if available, otherwise use sed)
if command -v jq &> /dev/null; then
  echo "$CONFIG" | jq '. + {"data-root": "/mnt/docker"}' | sudo tee /etc/docker/daemon.json > /dev/null
else
  # Fallback: use echo to create the config (simple version)
  echo '{
  "data-root": "/mnt/docker"
}' | sudo tee /etc/docker/daemon.json > /dev/null
fi

# Reload Docker daemon configuration
echo "🔄 Reloading Docker daemon..."
systemctl daemon-reload
systemctl restart docker

# Verify configuration
echo "✅ Docker storage configuration completed!"
echo ""
echo "📊 Docker configuration:"
docker info | grep -A 2 "Docker Root Dir"

# Show available space
echo ""
echo "💾 Disk space usage:"
df -h /dev/root /mnt | tail -n +2 | awk '{print $1 "\t" $4 " available (" $5 " used)"}'

echo ""
echo "🎉 Docker is now configured to use /mnt for storage!"
