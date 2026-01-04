# Architecture Documentation

## Overview

This infrastructure project implements a production-ready Kubernetes platform using RKE2 and Rancher on AWS, designed to host the veterinary application.

## Architecture Diagram

```
                                    ┌─────────────────────────────────────┐
                                    │         Internet Users              │
                                    └──────────────┬──────────────────────┘
                                                   │
                                                   ▼
                                    ┌─────────────────────────────────────┐
                                    │     AWS Route 53 (DNS)             │
                                    └──────────────┬──────────────────────┘
                                                   │
                                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                   AWS Region (us-east-1)                         │
│                                                                                   │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                        VPC (10.0.0.0/16)                                 │  │
│  │                                                                           │  │
│  │  ┌────────────────────────────┐       ┌─────────────────────────────┐   │  │
│  │  │   Availability Zone 1a     │       │   Availability Zone 1b      │   │  │
│  │  │                             │       │                             │   │  │
│  │  │  ┌──────────────────────┐  │       │  ┌──────────────────────┐  │   │  │
│  │  │  │  Public Subnet       │  │       │  │  Public Subnet       │  │   │  │
│  │  │  │  10.0.1.0/24         │  │       │  │  10.0.2.0/24         │  │   │  │
│  │  │  │                      │  │       │  │                      │  │   │  │
│  │  │  │  ┌────────────────┐ │  │       │  │ ┌────────────────┐  │  │   │  │
│  │  │  │  │      ALB       │ │  │       │  │ │   NAT Gateway  │  │  │   │  │
│  │  │  │  └────────┬───────┘ │  │       │  │ └────────────────┘  │  │   │  │
│  │  │  └───────────┼──────────┘  │       │  └──────────────────────┘  │   │  │
│  │  │              │              │       │                             │   │  │
│  │  │  ┌───────────┼──────────┐  │       │  ┌──────────────────────┐  │   │  │
│  │  │  │  Private Subnet      │  │       │  │  Private Subnet      │  │   │  │
│  │  │  │  10.0.10.0/24        │  │       │  │  10.0.11.0/24        │  │   │  │
│  │  │  │           │          │  │       │  │                      │  │   │  │
│  │  │  │  ┌────────▼───────┐ │  │       │  │  ┌────────────────┐ │  │   │  │
│  │  │  │  │  RKE2 Server   │ │  │       │  │  │  RKE2 Agent    │ │  │   │  │
│  │  │  │  │  Control Plane │ │  │       │  │  │  Worker Node   │ │  │   │  │
│  │  │  │  │                │ │  │       │  │  │                │ │  │   │  │
│  │  │  │  │  - API Server  │ │  │       │  │  │  - kubelet     │ │  │   │  │
│  │  │  │  │  - etcd        │ │  │       │  │  │  - containerd  │ │  │   │  │
│  │  │  │  │  - Scheduler   │ │  │       │  │  │  - vet_app     │ │  │   │  │
│  │  │  │  │  - Rancher     │ │  │       │  │  └────────────────┘ │  │   │  │
│  │  │  │  └────────────────┘ │  │       │  │                      │  │   │  │
│  │  │  └───────────────────────┘  │       │  └──────────────────────┘  │   │  │
│  │  └────────────────────────────┘       └─────────────────────────┘   │  │
│  │                                                                       │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Components

### 1. Network Layer

#### VPC (Virtual Private Cloud)
- CIDR: `10.0.0.0/16`
- DNS support and hostnames enabled
- Multi-AZ deployment for high availability

#### Subnets
**Public Subnets:**
- `10.0.1.0/24` (AZ1) and `10.0.2.0/24` (AZ2)
- Auto-assign public IPs
- Host: ALB, NAT Gateway, and jump hosts

**Private Subnets:**
- `10.0.10.0/24` (AZ1) and `10.0.11.0/24` (AZ2)
- No direct internet access
- Host: RKE2 nodes and application workloads

#### Network Gateways
- **Internet Gateway**: Allows public subnet internet access
- **NAT Gateways**: Enable private subnet outbound internet access (one per AZ)

#### Security Groups
**RKE2 Nodes Security Group:**
- Inbound: 6443 (K8s API), 9345 (RKE2 supervisor), 22 (SSH), 80/443 (HTTP/HTTPS)
- Outbound: All traffic
- Internal: All traffic between cluster nodes

**Load Balancer Security Group:**
- Inbound: 80 (HTTP), 443 (HTTPS)
- Outbound: All traffic to RKE2 nodes

### 2. Compute Layer

#### EC2 Instances

**Server Nodes (Control Plane):**
- Instance Type: `t3.medium` (dev) / `t3.large` (prod)
- Count: 1 (dev) / 3 (prod) for HA
- OS: Ubuntu 22.04 LTS
- Role: Run K8s control plane components and Rancher

**Agent Nodes (Workers):**
- Instance Type: `t3.medium` (dev) / `t3.large` (prod)
- Count: 2 (dev) / 3+ (prod)
- OS: Ubuntu 22.04 LTS
- Role: Run application workloads

**Storage:**
- Root volume: 50GB GP3 EBS (encrypted)
- Additional volumes for persistent data as needed

#### Application Load Balancer
- Type: Application Load Balancer (Layer 7)
- Scheme: Internet-facing
- Target: RKE2 server nodes (port 443)
- Health checks: HTTPS to `/ping`
- SSL/TLS termination
- HTTP to HTTPS redirect

### 3. RKE2 Cluster

#### Control Plane (Server Nodes)
**Components:**
- **kube-apiserver**: Kubernetes API endpoint
- **etcd**: Distributed key-value store for cluster state
- **kube-scheduler**: Pod scheduling
- **kube-controller-manager**: Cluster control loops
- **cloud-controller-manager**: AWS integration

**Configuration:**
- CNI: Calico for network policies
- Ingress: Disabled (using custom)
- TLS: Auto-generated certificates

#### Worker Nodes (Agent Nodes)
**Components:**
- **kubelet**: Node agent
- **containerd**: Container runtime
- **kube-proxy**: Network proxy

### 4. Rancher Management Platform

**Deployment:**
- Namespace: `cattle-system`
- Helm chart: `rancher-latest/rancher`
- Replicas: 1 (dev) / 3 (prod)
- Version: 2.7.9

**Dependencies:**
- **cert-manager**: Certificate management (namespace: `cert-manager`)
- **ingress-nginx**: Ingress controller

**Features:**
- Multi-cluster management
- RBAC integration
- Monitoring and alerting
- Application catalog
- CI/CD integration

### 5. Application Layer

#### Veterinary Application
**Deployment:**
- Namespace: `vet-app`
- Replicas: 2 (scalable)
- Container: Python 3.9 with vet_app code
- Resources:
  - Requests: 100m CPU, 128Mi memory
  - Limits: 200m CPU, 256Mi memory

**Services:**
- Type: ClusterIP
- Port: 80 → 8000
- Selector: app=vet-app

**Storage:**
- PVC: 5Gi for application data
- StorageClass: standard (AWS EBS)

**Configuration:**
- ConfigMap: Environment variables
- Secrets: Sensitive data (optional)

**Networking:**
- Ingress: nginx ingress controller
- TLS: cert-manager with Let's Encrypt
- Domain: vet-app.example.com

## Data Flow

### User Request Flow
1. User accesses `https://vet-app.example.com`
2. DNS resolves to ALB public IP
3. ALB forwards to Rancher/Ingress on server nodes
4. Ingress controller routes to vet-app service
5. Service load-balances to vet-app pods
6. Pod processes request and returns response

### Management Flow
1. Admin accesses Rancher UI via ALB
2. Rancher authenticates user
3. Admin manages cluster via Rancher UI
4. Rancher calls K8s API server
5. Changes propagate to cluster components

## Security

### Network Security
- Public subnets isolated from private
- NAT Gateway for controlled outbound
- Security groups limit inbound traffic
- TLS encryption for all external traffic

### Access Control
- SSH key-based authentication
- RBAC in Kubernetes
- Rancher authentication integration
- Encrypted EBS volumes

### Secrets Management
- Kubernetes secrets for sensitive data
- Terraform sensitive variables
- AWS Secrets Manager (optional)

## Scalability

### Horizontal Scaling
- Add more agent nodes for capacity
- Scale deployments with `kubectl scale`
- Auto-scaling groups (future enhancement)

### Vertical Scaling
- Upgrade instance types
- Increase pod resource limits
- Add more EBS volumes

## High Availability

### Control Plane HA (Production)
- 3 server nodes across 3 AZs
- etcd quorum (2 out of 3)
- Load balanced API access

### Application HA
- Multiple replicas per deployment
- Anti-affinity rules (optional)
- Health checks and auto-restart

### Data HA
- EBS snapshots for backups
- Multi-AZ deployment
- Persistent volume replication (optional)

## Monitoring & Logging

### Future Enhancements
- Prometheus for metrics
- Grafana for visualization
- ELK stack for logging
- AWS CloudWatch integration

## Disaster Recovery

### Backup Strategy
- Terraform state in S3
- etcd snapshots (automated)
- Application data backups
- Configuration as code in Git

### Recovery Plan
1. Restore Terraform state
2. Re-apply infrastructure
3. Restore etcd snapshot
4. Redeploy applications
5. Restore data from backups

## Cost Optimization

### Development Environment
- Single server node (t3.medium)
- 2 agent nodes (t3.medium)
- Single NAT Gateway
- Estimated cost: ~$200-300/month

### Production Environment
- 3 server nodes (t3.large)
- 3+ agent nodes (t3.large)
- Multi-AZ NAT Gateways
- Estimated cost: ~$600-800/month

### Optimization Tips
- Use Spot instances for non-critical workloads
- Right-size instances based on metrics
- Schedule start/stop for dev environments
- Use reserved instances for production

## Future Enhancements

1. **CI/CD Pipeline**: GitHub Actions, ArgoCD
2. **Service Mesh**: Istio or Linkerd
3. **Monitoring**: Prometheus, Grafana
4. **Logging**: EFK/ELK stack
5. **Backup**: Velero for K8s backups
6. **Auto-scaling**: HPA and cluster autoscaler
7. **Multi-cluster**: Rancher multi-cluster management
8. **GitOps**: ArgoCD for declarative deployments
