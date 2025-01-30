#!/bin/sh

apt-get update
apt-get install -y curl

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s || echo "Failed to install K3s server"
sudo kubectl apply -f ./remote/confs
