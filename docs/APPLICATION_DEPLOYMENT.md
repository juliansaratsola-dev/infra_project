# Application Deployment Notes

## Current Application Status

The `vet_app` is a **CLI (Command Line Interface)** application, not a web service. This affects how it should be deployed in Kubernetes.

## Deployment Options

### Option 1: Keep as CLI Application (Current State)

If the application remains a CLI tool:

**Considerations:**
- No need for Service or Ingress resources
- Deployment will continuously restart containers (they exit after running)
- Better suited as a Job or CronJob instead of a Deployment

**Recommended K8s Resources:**
```yaml
# Use Job for one-time execution
apiVersion: batch/v1
kind: Job
metadata:
  name: vet-app-job
spec:
  template:
    spec:
      containers:
      - name: vet-app
        image: vet-app:latest
        command: ["python", "main.py"]
      restartPolicy: OnFailure
```

**Or use CronJob for scheduled execution:**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: vet-app-cronjob
spec:
  schedule: "0 0 * * *"  # Daily at midnight
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: vet-app
            image: vet-app:latest
            command: ["python", "main.py"]
          restartPolicy: OnFailure
```

### Option 2: Convert to Web Service (Recommended for K8s)

To properly utilize Kubernetes features, consider converting the CLI app to a web service:

**Steps:**

1. **Add a web framework** (Flask/FastAPI):
```python
# In vet_app/web.py
from flask import Flask, jsonify, request
from sistema_veterinaria import SistemaVeterinaria

app = Flask(__name__)
sistema = SistemaVeterinaria()

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

@app.route('/api/tutores', methods=['GET', 'POST'])
def tutores():
    if request.method == 'POST':
        data = request.json
        tutor = sistema.registrar_tutor(
            data['nombre'], data['apellido'], 
            data['telefono'], data['email'], data['direccion']
        )
        return jsonify({"id": tutor.id_tutor})
    else:
        # Return list of tutores
        return jsonify({"tutores": []})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

2. **Update Dockerfile**:
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY vet_app/ /app/
RUN pip install flask
EXPOSE 8000
CMD ["python", "web.py"]
```

3. **Update deployment.yaml**:
```yaml
# Uncomment ports, probes in the existing deployment
ports:
- containerPort: 8000
  name: http
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 10
```

### Option 3: Hybrid Approach

Keep both CLI and web interface:

```python
# web.py - REST API
# main.py - CLI interface
# Both use sistema_veterinaria.py
```

Then you can:
- Deploy web service in Kubernetes (with Service/Ingress)
- Use CLI for administrative tasks via `kubectl exec`

## Current Manifests Status

The provided Kubernetes manifests (deployment.yaml, service.yaml, ingress.yaml) are configured for **Option 2** (web service), but the application code is **Option 1** (CLI).

**Actions Needed:**

Choose one of the following:

1. **Update manifests for CLI usage**:
   - Replace Deployment with Job/CronJob
   - Remove Service and Ingress
   - Keep ConfigMap and PVC

2. **Update application for web service**:
   - Add web framework
   - Implement REST API endpoints
   - Keep current manifests (uncomment port configs)

3. **Hybrid deployment**:
   - Add web interface alongside CLI
   - Deploy both as separate containers or combined

## Image Registry

The current configuration uses `image: vet-app:latest` which assumes:
- Image exists in a registry
- Kubernetes can pull it

**To use this:**

1. **Build the image**:
```bash
docker build -t vet-app:latest .
```

2. **Push to registry**:

**Docker Hub:**
```bash
docker tag vet-app:latest your-username/vet-app:latest
docker push your-username/vet-app:latest
```

**AWS ECR:**
```bash
aws ecr create-repository --repository-name vet-app
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
docker tag vet-app:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/vet-app:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/vet-app:latest
```

3. **Update deployment.yaml**:
```yaml
image: your-username/vet-app:latest
# or
image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/vet-app:latest
```

## Recommendations

For a production-ready deployment:

1. **Convert to web service** - Best for Kubernetes
2. **Use a proper image registry** - Docker Hub, ECR, or GCR
3. **Implement health endpoints** - For liveness/readiness probes
4. **Add proper logging** - For observability
5. **Use ConfigMaps/Secrets** - For configuration
6. **Implement API versioning** - For updates
7. **Add authentication** - For API security

## Quick Start for Web Service Conversion

If you want to quickly convert to a web service:

```bash
# 1. Install Flask in requirements.txt
echo "flask==3.0.0" >> vet_app/requirements.txt

# 2. Create a simple web interface
cat > vet_app/web.py << 'EOF'
from flask import Flask, jsonify
import sys

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "service": "Veterinary Management System",
        "status": "running"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
EOF

# 3. Update Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY vet_app/ /app/
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8000
CMD ["python", "web.py"]
EOF

# 4. Build and test
docker build -t vet-app:latest .
docker run -p 8000:8000 vet-app:latest
# Test: curl http://localhost:8000/health

# 5. Push to registry and deploy
docker tag vet-app:latest your-username/vet-app:latest
docker push your-username/vet-app:latest

# 6. Update deployment.yaml with your image
# 7. Deploy to Kubernetes
kubectl apply -f k8s/manifests/
```

## Support

For questions or issues with deployment, refer to:
- [README.md](../README.md) - Main documentation
- [QUICKSTART.md](./QUICKSTART.md) - Deployment guide
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
