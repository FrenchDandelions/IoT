#!/bin/bash

# Variables
MASTER_IP="192.168.56.110"
apt-get update
apt-get install -y curl
# Fetch the token from the master
echo "Fetching token from the master node..."
TOKEN=$(cat /tmp/confs/token)
if [ -z "$TOKEN" ]; then
    echo "Failed to retrieve the token from the master node."
    exit 1
fi

# Install k3s agent
echo "Installing k3s agent..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" \
    K3S_TOKEN="$TOKEN" \
    K3S_URL="https://$MASTER_IP:6443" sh - || echo "Failed to install K3s agent"
