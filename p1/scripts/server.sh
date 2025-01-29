#!/bin/sh

apt-get update
apt-get install -y curl

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s || echo "Failed to install K3s server"

mkdir -p /vagrant/tmp
sudo cp /var/lib/rancher/k3s/server/token /vagrant/tmp
apt-get install net-tools -y
# commande pour config : /sbin/ifconfig eth1