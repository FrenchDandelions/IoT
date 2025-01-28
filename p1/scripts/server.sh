apt-get update
apt-get install -y curl
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" K3S_TOKEN=12345 sh -s || echo "Failed to install K3s server"
mv /var/lib/rancher/k3s/server/token /tmp/confs/