#!/bin/bash
# Deploy entire infrastructure and application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SSH_KEY=${SSH_KEY:-"~/.ssh/vet-infra-key.pem"}
TERRAFORM_DIR="terraform"
SCRIPTS_DIR="scripts"
K8S_DIR="k8s/manifests"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Vet Infra - Full Deployment Script  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Step 1: Check prerequisites
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Error: terraform not installed${NC}" >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo -e "${RED}Error: aws cli not installed${NC}" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}Error: kubectl not installed${NC}" >&2; exit 1; }
echo -e "${GREEN}✓ All prerequisites satisfied${NC}"

# Step 2: Deploy infrastructure with Terraform
echo -e "\n${YELLOW}[2/7] Deploying infrastructure with Terraform...${NC}"
cd "$TERRAFORM_DIR"
terraform init
terraform apply -auto-approve

# Extract outputs
SERVER_IP=$(terraform output -json rke2_server_public_ips | jq -r '.[0]')
SERVER_PRIVATE_IP=$(terraform output -json rke2_server_private_ips | jq -r '.[0]')
AGENT_IPS=$(terraform output -json rke2_agent_public_ips | jq -r '.[]')
LB_DNS=$(terraform output -raw load_balancer_dns)
cd ..

echo -e "${GREEN}✓ Infrastructure deployed${NC}"
echo -e "  Server IP: ${SERVER_IP}"
echo -e "  Load Balancer: ${LB_DNS}"

# Step 3: Wait for instances to be ready
echo -e "\n${YELLOW}[3/7] Waiting for instances to be ready...${NC}"
sleep 60
echo -e "${GREEN}✓ Instances ready${NC}"

# Step 4: Install RKE2 on server
echo -e "\n${YELLOW}[4/7] Installing RKE2 on server node...${NC}"
cd "$SCRIPTS_DIR"
TOKEN=$(openssl rand -base64 32)
./install_rke2_server.sh "$SERVER_IP" "$SSH_KEY" "$TOKEN"
echo -e "${GREEN}✓ RKE2 server installed${NC}"

# Step 5: Install RKE2 on agents
echo -e "\n${YELLOW}[5/7] Installing RKE2 on agent nodes...${NC}"
for AGENT_IP in $AGENT_IPS; do
    echo "Installing on agent: $AGENT_IP"
    ./install_rke2_agent.sh "$AGENT_IP" "$SERVER_PRIVATE_IP" "$SSH_KEY" "$TOKEN"
done
echo -e "${GREEN}✓ RKE2 agents installed${NC}"

# Step 6: Install Rancher
echo -e "\n${YELLOW}[6/7] Installing Rancher...${NC}"
./install_rancher.sh "$SERVER_IP" "$SSH_KEY" "2.7.9" "$LB_DNS"
echo -e "${GREEN}✓ Rancher installed${NC}"

# Step 7: Configure kubectl and deploy application
echo -e "\n${YELLOW}[7/7] Deploying application...${NC}"
cd ..

# Get kubeconfig
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$SERVER_IP":/etc/rancher/rke2/rke2.yaml ./kubeconfig
sed -i "s/127.0.0.1/$SERVER_IP/g" kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig

# Deploy application
kubectl apply -f "$K8S_DIR"

# Wait for deployment
kubectl -n vet-app rollout status deployment/vet-app --timeout=5m

echo -e "${GREEN}✓ Application deployed${NC}"

# Final summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Rancher UI: https://$LB_DNS"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "Kubeconfig: $(pwd)/kubeconfig"
echo ""
echo "To access the application:"
echo "  kubectl -n vet-app get all"
echo ""
echo "To destroy infrastructure:"
echo "  cd terraform && terraform destroy"
echo ""
