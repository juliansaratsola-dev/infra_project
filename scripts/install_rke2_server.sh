#!/bin/bash
# Install RKE2 on server nodes

set -e

SERVER_IP=$1
SSH_KEY=$2
CLUSTER_TOKEN=$3

if [ -z "$SERVER_IP" ] || [ -z "$SSH_KEY" ] || [ -z "$CLUSTER_TOKEN" ]; then
    echo "Usage: $0 <server_ip> <ssh_key_path> <cluster_token>"
    exit 1
fi

echo "Installing RKE2 server on $SERVER_IP..."

# Copy RKE2 config
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$SERVER_IP" "sudo mkdir -p /etc/rancher/rke2"

ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "cat <<EOF | sudo tee /etc/rancher/rke2/config.yaml
token: $CLUSTER_TOKEN
tls-san:
  - $SERVER_IP
write-kubeconfig-mode: \"0644\"
cni:
  - calico
disable:
  - rke2-ingress-nginx
EOF"

# Install RKE2
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "curl -sfL https://get.rke2.io | sudo sh -"

# Enable and start RKE2 server
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "sudo systemctl enable rke2-server.service"
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "sudo systemctl start rke2-server.service"

echo "Waiting for RKE2 server to start..."
sleep 30

# Verify installation
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "sudo systemctl status rke2-server.service"

# Set up kubectl
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "sudo ln -s /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl || true"
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "mkdir -p ~/.kube"
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "sudo cp /etc/rancher/rke2/rke2.yaml ~/.kube/config"
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "sudo chown ubuntu:ubuntu ~/.kube/config"

# Verify cluster
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "kubectl get nodes"

echo "RKE2 server installation completed successfully!"
echo "You can retrieve the kubeconfig with:"
echo "scp -i $SSH_KEY ubuntu@$SERVER_IP:/etc/rancher/rke2/rke2.yaml ./kubeconfig"
