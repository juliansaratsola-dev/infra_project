#!/bin/bash
# Install Rancher on RKE2 cluster

set -e

SERVER_IP=$1
SSH_KEY=$2
RANCHER_VERSION=${3:-"2.7.9"}
HOSTNAME=${4:-"rancher.local"}
BOOTSTRAP_PASSWORD=${5:-""}  # Optional: leave empty for auto-generated password

if [ -z "$SERVER_IP" ] || [ -z "$SSH_KEY" ]; then
    echo "Usage: $0 <server_ip> <ssh_key_path> [rancher_version] [hostname] [bootstrap_password]"
    exit 1
fi

echo "Installing Rancher $RANCHER_VERSION on RKE2 cluster..."

# Add Helm repo and install cert-manager
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    kubectl create namespace cattle-system || true && \
    kubectl create namespace cert-manager || true && \
    helm repo add jetstack https://charts.jetstack.io && \
    helm repo add rancher-latest https://releases.rancher.com/server-charts/latest && \
    helm repo update"

# Install cert-manager
echo "Installing cert-manager..."
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml && \
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.crds.yaml && \
    helm install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --version v1.13.0"

echo "Waiting for cert-manager to be ready..."
sleep 30

# Install Rancher with or without bootstrap password
echo "Installing Rancher..."
if [ -n "$BOOTSTRAP_PASSWORD" ]; then
    echo "Using provided bootstrap password..."
    ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml && \
        helm install rancher rancher-latest/rancher \
            --namespace cattle-system \
            --set hostname=$HOSTNAME \
            --set bootstrapPassword=$BOOTSTRAP_PASSWORD \
            --set replicas=1"
else
    echo "Using auto-generated bootstrap password..."
    ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml && \
        helm install rancher rancher-latest/rancher \
            --namespace cattle-system \
            --set hostname=$HOSTNAME \
            --set replicas=1"
fi

echo "Waiting for Rancher to be ready..."
sleep 60

# Check Rancher status
ssh -i "$SSH_KEY" ubuntu@"$SERVER_IP" "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml && \
    kubectl -n cattle-system rollout status deploy/rancher"

echo ""
echo "=========================================="
echo "Rancher installation completed!"
echo "=========================================="
echo "Access Rancher at: https://$HOSTNAME"

if [ -n "$BOOTSTRAP_PASSWORD" ]; then
    echo "Bootstrap password: $BOOTSTRAP_PASSWORD"
else
    echo ""
    echo "To retrieve the auto-generated password, run:"
    echo "kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{\"\\n\"}}'"
    echo ""
    echo "Or SSH to the server and run:"
    echo "ssh -i $SSH_KEY ubuntu@$SERVER_IP"
    echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml"
    echo "kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{\"\\n\"}}'"
fi

echo ""
echo "To access Rancher, you may need to:"
echo "1. Configure DNS to point $HOSTNAME to the load balancer"
echo "2. Or add entry to /etc/hosts: <LB_IP> $HOSTNAME"
echo "=========================================="
