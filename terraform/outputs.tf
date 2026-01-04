# Outputs for the infrastructure project

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.network.private_subnet_ids
}

output "rke2_server_public_ips" {
  description = "Public IPs of RKE2 server nodes"
  value       = module.compute.server_public_ips
}

output "rke2_server_private_ips" {
  description = "Private IPs of RKE2 server nodes"
  value       = module.compute.server_private_ips
}

output "rke2_agent_public_ips" {
  description = "Public IPs of RKE2 agent nodes"
  value       = module.compute.agent_public_ips
}

output "rke2_agent_private_ips" {
  description = "Private IPs of RKE2 agent nodes"
  value       = module.compute.agent_private_ips
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.compute.load_balancer_dns
}

output "rancher_url" {
  description = "URL to access Rancher"
  value       = "https://${module.compute.load_balancer_dns}"
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig"
  value       = "scp -i <your-key>.pem ubuntu@${module.compute.server_public_ips[0]}:/etc/rancher/rke2/rke2.yaml ./kubeconfig"
}
