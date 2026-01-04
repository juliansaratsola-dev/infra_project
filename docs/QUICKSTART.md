# Quick Start Guide - Infraestructura Veterinaria

Esta guía rápida te ayudará a desplegar la infraestructura en menos de 30 minutos.

## Prerequisitos Rápidos

```bash
# Verificar instalaciones
terraform --version
aws --version
kubectl version --client

# Configurar AWS CLI
aws configure
```

## Despliegue en 5 Pasos

### 1️⃣ Crear Key Pair

```bash
aws ec2 create-key-pair --key-name vet-infra-key --query 'KeyMaterial' --output text > ~/.ssh/vet-infra-key.pem
chmod 400 ~/.ssh/vet-infra-key.pem
```

### 2️⃣ Configurar Terraform

```bash
cd terraform
cat > terraform.tfvars <<EOF
key_name           = "vet-infra-key"
rke2_cluster_token = "$(openssl rand -base64 32)"
EOF
```

### 3️⃣ Desplegar Infraestructura

```bash
terraform init
terraform apply -auto-approve
```

⏱️ Esto tomará aproximadamente 5-10 minutos.

### 4️⃣ Instalar RKE2 y Rancher

```bash
cd ../scripts

# Obtener IPs
SERVER_IP=$(cd ../terraform && terraform output -json rke2_server_public_ips | jq -r '.[0]')
SERVER_PRIVATE_IP=$(cd ../terraform && terraform output -json rke2_server_private_ips | jq -r '.[0]')
TOKEN=$(cd ../terraform && terraform output -json | jq -r '.rke2_cluster_token.value // "default-token"')

# Instalar RKE2 Server
./install_rke2_server.sh $SERVER_IP ~/.ssh/vet-infra-key.pem "$TOKEN"

# Instalar RKE2 Agents (para cada agente)
AGENT_IPS=$(cd ../terraform && terraform output -json rke2_agent_public_ips | jq -r '.[]')
for AGENT_IP in $AGENT_IPS; do
    ./install_rke2_agent.sh $AGENT_IP $SERVER_PRIVATE_IP ~/.ssh/vet-infra-key.pem "$TOKEN"
done

# Instalar Rancher
LB_DNS=$(cd ../terraform && terraform output -raw load_balancer_dns)
./install_rancher.sh $SERVER_IP ~/.ssh/vet-infra-key.pem "2.7.9" "$LB_DNS"
```

⏱️ Esto tomará aproximadamente 10-15 minutos.

### 5️⃣ Configurar kubectl y Desplegar App

```bash
# Obtener kubeconfig
scp -i ~/.ssh/vet-infra-key.pem ubuntu@$SERVER_IP:/etc/rancher/rke2/rke2.yaml ./kubeconfig
sed -i "s/127.0.0.1/$SERVER_IP/g" kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig

# Verificar cluster
kubectl get nodes

# Desplegar aplicación
cd ../k8s/manifests
kubectl apply -f .

# Verificar despliegue
kubectl -n vet-app get all
```

## Acceso

### Rancher UI
```bash
# Obtener URL
echo "https://$(cd ../../terraform && terraform output -raw load_balancer_dns)"

# Credenciales iniciales
# Usuario: admin
# Password: admin
```

### Aplicación Veterinaria
```bash
kubectl -n vet-app get ingress
```

## Comandos Útiles

```bash
# Ver estado del cluster
kubectl get nodes
kubectl get pods -A

# Ver logs de la app
kubectl -n vet-app logs -f -l app=vet-app

# Escalar la app
kubectl -n vet-app scale deployment/vet-app --replicas=3

# Destruir todo
cd terraform
terraform destroy -auto-approve
```

## Troubleshooting Rápido

### RKE2 no inicia
```bash
ssh -i ~/.ssh/vet-infra-key.pem ubuntu@$SERVER_IP "sudo journalctl -u rke2-server -n 50"
```

### Rancher no accesible
```bash
kubectl -n cattle-system get pods
kubectl -n cattle-system logs -l app=rancher
```

### App no se despliega
```bash
kubectl -n vet-app describe deployment vet-app
kubectl -n vet-app get events
```

## Próximos Pasos

- Revisar la documentación completa en [README.md](../README.md)
- Configurar monitoreo y logging
- Implementar CI/CD
- Configurar backups
