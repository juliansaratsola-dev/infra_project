#!/bin/bash
# User data script for RKE2 agent node

set -e

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y curl wget

# Set hostname
sudo hostnamectl set-hostname rke2-agent-${node_index}

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Configure system for RKE2
cat <<EOF | sudo tee /etc/sysctl.d/99-rke2.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Create RKE2 config directory
sudo mkdir -p /etc/rancher/rke2

# RKE2 agent configuration will be applied via scripts/install_rke2.sh
# This user data just prepares the system

# Log completion
echo "RKE2 agent node preparation completed at $(date)" | sudo tee /var/log/user-data-complete.log
