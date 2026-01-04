# RKE2 Server Configuration
token: ${cluster_token}
tls-san:
  - localhost
  - 127.0.0.1
write-kubeconfig-mode: "0644"
cni:
  - calico
disable:
  - rke2-ingress-nginx
