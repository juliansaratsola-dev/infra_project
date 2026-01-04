# Infrastructure Project - Veterinary Application

Este proyecto proporciona una infraestructura completa usando **Terraform**, **RKE2**, **Rancher** y **Kubernetes** para desplegar la aplicación veterinaria.

## 📋 Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Arquitectura](#arquitectura)
- [Requisitos Previos](#requisitos-previos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Instalación y Configuración](#instalación-y-configuración)
- [Despliegue](#despliegue)
- [Gestión del Cluster](#gestión-del-cluster)
- [Troubleshooting](#troubleshooting)

## 🎯 Descripción General

Este proyecto implementa una infraestructura completa en AWS para ejecutar la aplicación veterinaria en un cluster Kubernetes gestionado por Rancher. La infraestructura incluye:

- **Terraform**: Infraestructura como código para provisionamiento automatizado
- **RKE2**: Distribución de Kubernetes certificada y segura
- **Rancher**: Plataforma de gestión de clusters Kubernetes
- **Kubernetes**: Orquestación de contenedores para la aplicación

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │                   VPC (10.0.0.0/16)                │    │
│  │                                                     │    │
│  │  ┌──────────────┐         ┌──────────────┐        │    │
│  │  │ Public Subnet│         │Private Subnet│        │    │
│  │  │   10.0.1.0/24│         │  10.0.10.0/24│        │    │
│  │  │              │         │              │        │    │
│  │  │  ┌────────┐  │         │  ┌────────┐  │        │    │
│  │  │  │  ALB   │  │         │  │ RKE2   │  │        │    │
│  │  │  │        │──┼─────────┼─▶│ Server │  │        │    │
│  │  │  └────────┘  │         │  │ Node   │  │        │    │
│  │  │              │         │  └────────┘  │        │    │
│  │  │              │         │              │        │    │
│  │  │              │         │  ┌────────┐  │        │    │
│  │  │              │         │  │ RKE2   │  │        │    │
│  │  │              │         │  │ Agent  │  │        │    │
│  │  │              │         │  │ Nodes  │  │        │    │
│  │  │              │         │  └────────┘  │        │    │
│  │  └──────────────┘         └──────────────┘        │    │
│  │                                                     │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Componentes:

1. **Red (Network)**
   - VPC con subredes públicas y privadas
   - Internet Gateway y NAT Gateway
   - Security Groups para control de acceso
   - Application Load Balancer para Rancher

2. **Computación (Compute)**
   - Instancias EC2 para nodos RKE2 server
   - Instancias EC2 para nodos RKE2 agent
   - Auto Scaling (opcional)

3. **RKE2 Cluster**
   - Nodos server para control plane
   - Nodos agent para workloads
   - CNI: Calico para networking

4. **Rancher**
   - Gestión centralizada del cluster
   - UI web para administración
   - RBAC y autenticación

5. **Aplicación Veterinaria**
   - Deployments en Kubernetes
   - Services para acceso interno
   - Ingress para acceso externo
   - Persistent storage para datos

## ✅ Requisitos Previos

### Software Necesario:

- **Terraform** >= 1.0 ([Instalar](https://www.terraform.io/downloads))
- **AWS CLI** >= 2.0 ([Instalar](https://aws.amazon.com/cli/))
- **kubectl** >= 1.24 ([Instalar](https://kubernetes.io/docs/tasks/tools/))
- **SSH Key pair** para acceso a instancias EC2

### Credenciales AWS:

```bash
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### SSH Key:

```bash
# Crear un nuevo key pair en AWS o usar uno existente
aws ec2 create-key-pair --key-name vet-infra-key --query 'KeyMaterial' --output text > ~/.ssh/vet-infra-key.pem
chmod 400 ~/.ssh/vet-infra-key.pem
```

## 📁 Estructura del Proyecto

```
.
├── Dockerfile                      # Container para vet_app
├── terraform/                      # Infraestructura como código
│   ├── main.tf                    # Configuración principal
│   ├── variables.tf               # Variables de Terraform
│   ├── outputs.tf                 # Outputs del despliegue
│   ├── modules/                   # Módulos reutilizables
│   │   ├── network/              # VPC, subnets, security groups
│   │   ├── compute/              # EC2 instances
│   │   └── rke2/                 # Configuración RKE2
│   └── environments/             # Configuraciones por ambiente
│       ├── dev/
│       └── prod/
├── scripts/                       # Scripts de instalación
│   ├── install_rke2_server.sh   # Instalar RKE2 server
│   ├── install_rke2_agent.sh    # Instalar RKE2 agent
│   └── install_rancher.sh       # Instalar Rancher
├── k8s/                          # Manifiestos Kubernetes
│   └── manifests/
│       ├── namespace.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── configmap.yaml
│       └── pvc.yaml
├── docs/                         # Documentación adicional
└── vet_app/                      # Aplicación veterinaria
```

## 🚀 Instalación y Configuración

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/juliansaratsola-dev/infra_project.git
cd infra_project
```

### Paso 2: Configurar Variables de Terraform

```bash
cd terraform

# Copiar el ejemplo de variables
cp environments/dev/terraform.tfvars.example terraform.tfvars

# Editar las variables
nano terraform.tfvars
```

Variables requeridas en `terraform.tfvars`:

```hcl
key_name           = "vet-infra-key"
rke2_cluster_token = "mi-token-super-secreto-123"
```

### Paso 3: Inicializar Terraform

```bash
terraform init
```

### Paso 4: Planificar el Despliegue

```bash
terraform plan
```

### Paso 5: Aplicar la Infraestructura

```bash
terraform apply
```

Esto creará:
- VPC con subredes públicas y privadas
- Security groups
- Instancias EC2 para RKE2
- Load balancer

**Nota**: Guarda los outputs, los necesitarás para los siguientes pasos.

## 🎯 Despliegue

### Paso 6: Instalar RKE2 en el Servidor

```bash
cd ../scripts

# Obtener la IP del servidor desde los outputs de Terraform
SERVER_IP=$(cd ../terraform && terraform output -raw rke2_server_public_ips | jq -r '.[0]')

# Instalar RKE2 en el nodo server
./install_rke2_server.sh $SERVER_IP ~/.ssh/vet-infra-key.pem "mi-token-super-secreto-123"
```

### Paso 7: Instalar RKE2 en los Agentes

```bash
# Para cada nodo agent
AGENT_IP=$(cd ../terraform && terraform output -raw rke2_agent_public_ips | jq -r '.[0]')
SERVER_PRIVATE_IP=$(cd ../terraform && terraform output -raw rke2_server_private_ips | jq -r '.[0]')

./install_rke2_agent.sh $AGENT_IP $SERVER_PRIVATE_IP ~/.ssh/vet-infra-key.pem "mi-token-super-secreto-123"
```

### Paso 8: Instalar Rancher

```bash
LB_DNS=$(cd ../terraform && terraform output -raw load_balancer_dns)

./install_rancher.sh $SERVER_IP ~/.ssh/vet-infra-key.pem "2.7.9" $LB_DNS
```

### Paso 9: Obtener el Kubeconfig

```bash
scp -i ~/.ssh/vet-infra-key.pem ubuntu@$SERVER_IP:/etc/rancher/rke2/rke2.yaml ./kubeconfig

# Actualizar el servidor en el kubeconfig
sed -i "s/127.0.0.1/$SERVER_IP/g" kubeconfig

export KUBECONFIG=$(pwd)/kubeconfig
```

### Paso 10: Desplegar la Aplicación Veterinaria

```bash
cd ../k8s/manifests

# Crear namespace
kubectl apply -f namespace.yaml

# Desplegar la aplicación
kubectl apply -f configmap.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Verificar el despliegue
kubectl -n vet-app get all
```

### Paso 11: Construir y Subir la Imagen Docker

```bash
cd ../..

# Construir la imagen
docker build -t vet-app:latest -f Dockerfile .

# Tag para registry (ejemplo con Docker Hub)
docker tag vet-app:latest your-dockerhub-username/vet-app:latest

# Push al registry
docker push your-dockerhub-username/vet-app:latest

# Actualizar el deployment con la imagen correcta
kubectl -n vet-app set image deployment/vet-app vet-app=your-dockerhub-username/vet-app:latest
```

## 🎛️ Gestión del Cluster

### Acceder a Rancher

1. Obtener la URL del Load Balancer:
   ```bash
   cd terraform
   terraform output rancher_url
   ```

2. Agregar entrada a `/etc/hosts`:
   ```bash
   echo "<LB-IP> rancher.local" | sudo tee -a /etc/hosts
   ```

3. Acceder en el navegador: `https://rancher.local`
   - Usuario: `admin`
   - Contraseña: `admin` (cambiar en primer login)

### Comandos Útiles de kubectl

```bash
# Ver nodos del cluster
kubectl get nodes

# Ver todos los pods
kubectl get pods -A

# Ver logs de la aplicación
kubectl -n vet-app logs -f deployment/vet-app

# Escalar la aplicación
kubectl -n vet-app scale deployment/vet-app --replicas=3

# Actualizar configuración
kubectl -n vet-app edit configmap vet-app-config

# Ver eventos
kubectl -n vet-app get events
```

## 🔧 Troubleshooting

### El cluster RKE2 no inicia

```bash
# Verificar logs del servidor
ssh -i ~/.ssh/vet-infra-key.pem ubuntu@$SERVER_IP
sudo journalctl -u rke2-server -f

# Verificar logs del agente
ssh -i ~/.ssh/vet-infra-key.pem ubuntu@$AGENT_IP
sudo journalctl -u rke2-agent -f
```

### Rancher no es accesible

```bash
# Verificar pods de Rancher
kubectl -n cattle-system get pods

# Ver logs de Rancher
kubectl -n cattle-system logs -l app=rancher

# Verificar cert-manager
kubectl -n cert-manager get pods
```

### La aplicación no se despliega

```bash
# Ver estado del deployment
kubectl -n vet-app describe deployment vet-app

# Ver logs de pods
kubectl -n vet-app logs -l app=vet-app

# Ver eventos
kubectl -n vet-app get events --sort-by='.lastTimestamp'
```

### Problemas de networking

```bash
# Verificar pods de Calico
kubectl -n kube-system get pods -l k8s-app=calico-node

# Test de conectividad
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Dentro del pod:
# wget -O- http://vet-app-service.vet-app.svc.cluster.local
```

## 🧹 Limpieza

Para destruir toda la infraestructura:

```bash
cd terraform
terraform destroy
```

**⚠️ ADVERTENCIA**: Esto eliminará TODOS los recursos creados, incluyendo datos.

## 📚 Referencias

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [RKE2 Documentation](https://docs.rke2.io/)
- [Rancher Documentation](https://rancher.com/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🤝 Contribuciones

Para contribuir al proyecto, por favor crea un Pull Request con tus cambios.

## 📄 Licencia

Este es un proyecto educativo para gestión de infraestructura.
