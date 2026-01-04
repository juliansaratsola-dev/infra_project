# Deployment Checklist

Use this checklist to track your deployment progress.

## Prerequisites

- [ ] AWS account configured with credentials
- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.0 installed
- [ ] kubectl >= 1.24 installed
- [ ] SSH key pair created in AWS
- [ ] Docker installed (for building images)

## Infrastructure Deployment

### Phase 1: Terraform Setup

- [ ] Clone repository
- [ ] Navigate to `terraform/` directory
- [ ] Copy `environments/dev/terraform.tfvars.example` to `terraform.tfvars`
- [ ] Edit `terraform.tfvars` with your values:
  - [ ] Set `key_name`
  - [ ] Set `rke2_cluster_token` (use `openssl rand -base64 32`)
  - [ ] Review and adjust network CIDR blocks if needed
- [ ] Run `terraform init`
- [ ] Run `terraform validate`
- [ ] Run `terraform plan` and review changes
- [ ] Run `terraform apply`
- [ ] Save outputs (IPs, DNS, etc.)

### Phase 2: RKE2 Installation

- [ ] Wait 2-3 minutes for EC2 instances to initialize
- [ ] Test SSH connection to server node
- [ ] Run `install_rke2_server.sh` script
- [ ] Verify RKE2 server is running
- [ ] Run `install_rke2_agent.sh` for each agent node
- [ ] Verify all agents joined the cluster

### Phase 3: Rancher Installation

- [ ] Run `install_rancher.sh` script
- [ ] Wait for Rancher pods to be ready
- [ ] Configure DNS or `/etc/hosts` for Rancher hostname
- [ ] Access Rancher UI via load balancer
- [ ] Change default admin password
- [ ] Configure Rancher settings

### Phase 4: Application Deployment

- [ ] Retrieve kubeconfig from server
- [ ] Set `KUBECONFIG` environment variable
- [ ] Verify kubectl can access cluster
- [ ] Build Docker image for vet_app
- [ ] Push image to container registry
- [ ] Update deployment.yaml with correct image
- [ ] Apply Kubernetes manifests
- [ ] Verify pods are running
- [ ] Configure ingress DNS
- [ ] Test application access

## Verification Steps

- [ ] All nodes show as "Ready" in kubectl
- [ ] Rancher UI is accessible
- [ ] Application pods are running
- [ ] Application is accessible via ingress
- [ ] Persistent storage is working
- [ ] Load balancer health checks passing

## Post-Deployment

- [ ] Set up monitoring (optional)
- [ ] Configure backups
- [ ] Document custom configurations
- [ ] Set up CI/CD pipeline
- [ ] Review security settings
- [ ] Plan for certificate management
- [ ] Schedule maintenance windows

## Troubleshooting Checklist

If something goes wrong, check these in order:

1. **Infrastructure Issues**
   - [ ] AWS credentials valid and have permissions
   - [ ] Terraform state is not corrupted
   - [ ] Security groups allow required traffic
   - [ ] Instances are running and healthy

2. **RKE2 Issues**
   - [ ] System requirements met (CPU, RAM, disk)
   - [ ] Network connectivity between nodes
   - [ ] Firewall rules allow RKE2 ports
   - [ ] Check logs: `journalctl -u rke2-server -f`

3. **Rancher Issues**
   - [ ] cert-manager pods running
   - [ ] Rancher pods running
   - [ ] DNS/hostname configured correctly
   - [ ] Load balancer health checks passing

4. **Application Issues**
   - [ ] Image available in registry
   - [ ] Namespace exists
   - [ ] Resource requests not exceeding node capacity
   - [ ] ConfigMaps and secrets created
   - [ ] Check pod logs for errors

## Useful Commands

```bash
# Infrastructure
make init              # Initialize Terraform
make plan              # Plan changes
make apply             # Apply changes
make outputs           # Show outputs
make destroy           # Destroy infrastructure

# Cluster Management
make get-kubeconfig    # Get kubeconfig
make status            # Show cluster status
kubectl get nodes      # List nodes
kubectl get pods -A    # List all pods

# Application
make deploy-app        # Deploy application
make scale-app REPLICAS=3  # Scale application
make logs              # View application logs

# Cleanup
make destroy-auto      # Destroy everything
```

## Estimated Time

- Infrastructure provisioning: ~10 minutes
- RKE2 installation: ~15 minutes
- Rancher installation: ~10 minutes
- Application deployment: ~5 minutes
- **Total: ~40 minutes**

## Cost Estimate

### Development Environment
- 1 t3.medium server: ~$30/month
- 2 t3.medium agents: ~$60/month
- Load balancer: ~$20/month
- EBS volumes: ~$10/month
- **Total: ~$120/month**

### Production Environment
- 3 t3.large servers: ~$180/month
- 3 t3.large agents: ~$180/month
- Load balancer: ~$20/month
- EBS volumes: ~$30/month
- NAT gateways: ~$90/month
- **Total: ~$500/month**

## Next Steps

After successful deployment:

1. **Security Hardening**
   - Restrict security group rules
   - Enable AWS CloudTrail
   - Configure network policies in Kubernetes
   - Set up secrets management

2. **Monitoring & Observability**
   - Install Prometheus
   - Set up Grafana dashboards
   - Configure log aggregation
   - Set up alerting

3. **Backup & Disaster Recovery**
   - Configure etcd backups
   - Set up volume snapshots
   - Document recovery procedures
   - Test backup restoration

4. **CI/CD Pipeline**
   - Set up GitHub Actions
   - Configure ArgoCD
   - Automate image builds
   - Implement GitOps workflow

5. **Performance Optimization**
   - Set up horizontal pod autoscaling
   - Configure cluster autoscaling
   - Optimize resource requests/limits
   - Implement caching strategies
