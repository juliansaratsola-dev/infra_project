# Rancher Helm Values
hostname: ${hostname}
replicas: 1
bootstrapPassword: "admin"

ingress:
  tls:
    source: rancher
