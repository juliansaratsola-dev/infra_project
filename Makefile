# Makefile for Infrastructure Project

.PHONY: help init plan apply destroy install-rke2 install-rancher deploy-app clean validate fmt

# Variables
TERRAFORM_DIR := terraform
SCRIPTS_DIR := scripts
K8S_DIR := k8s/manifests
SSH_KEY ?= ~/.ssh/vet-infra-key.pem

help: ## Show this help message
	@echo "Infrastructure Project - Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform
	cd $(TERRAFORM_DIR) && terraform init

validate: ## Validate Terraform configuration
	cd $(TERRAFORM_DIR) && terraform validate

fmt: ## Format Terraform files
	cd $(TERRAFORM_DIR) && terraform fmt -recursive

plan: ## Plan infrastructure changes
	cd $(TERRAFORM_DIR) && terraform plan

apply: ## Apply infrastructure changes
	cd $(TERRAFORM_DIR) && terraform apply

apply-auto: ## Apply infrastructure changes without confirmation
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

destroy: ## Destroy all infrastructure
	cd $(TERRAFORM_DIR) && terraform destroy

destroy-auto: ## Destroy all infrastructure without confirmation
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

outputs: ## Show Terraform outputs
	cd $(TERRAFORM_DIR) && terraform output

install-rke2: ## Install RKE2 on all nodes (requires SERVER_IP, AGENT_IPS, TOKEN)
	@if [ -z "$(SERVER_IP)" ]; then echo "Error: SERVER_IP not set"; exit 1; fi
	@if [ -z "$(TOKEN)" ]; then echo "Error: TOKEN not set"; exit 1; fi
	$(SCRIPTS_DIR)/install_rke2_server.sh $(SERVER_IP) $(SSH_KEY) $(TOKEN)

install-rancher: ## Install Rancher (requires SERVER_IP, LB_DNS)
	@if [ -z "$(SERVER_IP)" ]; then echo "Error: SERVER_IP not set"; exit 1; fi
	@if [ -z "$(LB_DNS)" ]; then echo "Error: LB_DNS not set"; exit 1; fi
	$(SCRIPTS_DIR)/install_rancher.sh $(SERVER_IP) $(SSH_KEY) 2.7.9 $(LB_DNS)

get-kubeconfig: ## Get kubeconfig from server (requires SERVER_IP)
	@if [ -z "$(SERVER_IP)" ]; then echo "Error: SERVER_IP not set"; exit 1; fi
	scp -i $(SSH_KEY) ubuntu@$(SERVER_IP):/etc/rancher/rke2/rke2.yaml ./kubeconfig
	sed -i "s/127.0.0.1/$(SERVER_IP)/g" kubeconfig
	@echo "Kubeconfig saved to ./kubeconfig"
	@echo "Export with: export KUBECONFIG=$(PWD)/kubeconfig"

deploy-app: ## Deploy application to Kubernetes
	kubectl apply -f $(K8S_DIR)
	kubectl -n vet-app rollout status deployment/vet-app

scale-app: ## Scale application (requires REPLICAS)
	@if [ -z "$(REPLICAS)" ]; then echo "Error: REPLICAS not set"; exit 1; fi
	kubectl -n vet-app scale deployment/vet-app --replicas=$(REPLICAS)

logs: ## Show application logs
	kubectl -n vet-app logs -f -l app=vet-app

status: ## Show cluster and application status
	@echo "=== Cluster Nodes ==="
	kubectl get nodes
	@echo ""
	@echo "=== Application Status ==="
	kubectl -n vet-app get all
	@echo ""
	@echo "=== Rancher Status ==="
	kubectl -n cattle-system get pods

build-image: ## Build Docker image for vet_app
	docker build -t vet-app:latest -f Dockerfile .

push-image: ## Push Docker image (requires REGISTRY)
	@if [ -z "$(REGISTRY)" ]; then echo "Error: REGISTRY not set (e.g., dockerhub-user/vet-app)"; exit 1; fi
	docker tag vet-app:latest $(REGISTRY):latest
	docker push $(REGISTRY):latest

deploy-all: ## Deploy everything (infrastructure + RKE2 + Rancher + app)
	./$(SCRIPTS_DIR)/deploy_all.sh

clean: ## Clean up local files
	rm -f kubeconfig
	rm -f $(TERRAFORM_DIR)/.terraform.lock.hcl
	rm -rf $(TERRAFORM_DIR)/.terraform

test-connection: ## Test SSH connection to server (requires SERVER_IP)
	@if [ -z "$(SERVER_IP)" ]; then echo "Error: SERVER_IP not set"; exit 1; fi
	ssh -i $(SSH_KEY) -o StrictHostKeyChecking=no ubuntu@$(SERVER_IP) "echo 'Connection successful!'"

ssh-server: ## SSH into server node (requires SERVER_IP)
	@if [ -z "$(SERVER_IP)" ]; then echo "Error: SERVER_IP not set"; exit 1; fi
	ssh -i $(SSH_KEY) ubuntu@$(SERVER_IP)

check-prereqs: ## Check if required tools are installed
	@echo "Checking prerequisites..."
	@command -v terraform >/dev/null 2>&1 && echo "✓ terraform" || echo "✗ terraform (not found)"
	@command -v aws >/dev/null 2>&1 && echo "✓ aws cli" || echo "✗ aws cli (not found)"
	@command -v kubectl >/dev/null 2>&1 && echo "✓ kubectl" || echo "✗ kubectl (not found)"
	@command -v docker >/dev/null 2>&1 && echo "✓ docker" || echo "✗ docker (not found)"
