#!/bin/sh

MASTER_IP="192.168.56.110"
apt-get update
apt-get install -y curl

echo "Fetching token from the master node..."
TOKEN=$(cat /vagrant/tmp/token)
if [ -z "$TOKEN" ]; then
    echo "Failed to retrieve the token from the master node."
    exit 1
fi

echo "Installing k3s agent..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" \
    K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh - || echo "Failed to install K3s agent"
apt-get install net-tools -y
# commande pour config : /sbin/ifconfig eth1