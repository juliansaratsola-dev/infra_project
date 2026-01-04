#!/bin/bash
# Install RKE2 on agent nodes

set -e

AGENT_IP=$1
SERVER_IP=$2
SSH_KEY=$3
CLUSTER_TOKEN=$4

if [ -z "$AGENT_IP" ] || [ -z "$SERVER_IP" ] || [ -z "$SSH_KEY" ] || [ -z "$CLUSTER_TOKEN" ]; then
    echo "Usage: $0 <agent_ip> <server_ip> <ssh_key_path> <cluster_token>"
    exit 1
fi

echo "Installing RKE2 agent on $AGENT_IP..."

# Copy RKE2 config
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$AGENT_IP" "sudo mkdir -p /etc/rancher/rke2"

ssh -i "$SSH_KEY" ubuntu@"$AGENT_IP" "cat <<EOF | sudo tee /etc/rancher/rke2/config.yaml
server: https://$SERVER_IP:9345
token: $CLUSTER_TOKEN
EOF"

# Install RKE2 agent
ssh -i "$SSH_KEY" ubuntu@"$AGENT_IP" "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=\"agent\" sudo sh -"

# Enable and start RKE2 agent
ssh -i "$SSH_KEY" ubuntu@"$AGENT_IP" "sudo systemctl enable rke2-agent.service"
ssh -i "$SSH_KEY" ubuntu@"$AGENT_IP" "sudo systemctl start rke2-agent.service"

echo "Waiting for RKE2 agent to start..."
sleep 20

# Verify installation
ssh -i "$SSH_KEY" ubuntu@"$AGENT_IP" "sudo systemctl status rke2-agent.service"

echo "RKE2 agent installation completed successfully!"
