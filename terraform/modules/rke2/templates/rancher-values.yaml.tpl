# Rancher Helm Values
hostname: ${hostname}
replicas: 1
%{ if bootstrap_password != "" ~}
bootstrapPassword: "${bootstrap_password}"
%{ else ~}
# Note: bootstrapPassword not set - will be auto-generated
# Retrieve it with: kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'
%{ endif ~}

ingress:
  tls:
    source: rancher
