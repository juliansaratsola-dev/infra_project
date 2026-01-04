output "server_public_ips" {
  description = "Public IPs of server nodes"
  value       = aws_instance.rke2_server[*].public_ip
}

output "server_private_ips" {
  description = "Private IPs of server nodes"
  value       = aws_instance.rke2_server[*].private_ip
}

output "agent_public_ips" {
  description = "Public IPs of agent nodes"
  value       = aws_instance.rke2_agent[*].public_ip
}

output "agent_private_ips" {
  description = "Private IPs of agent nodes"
  value       = aws_instance.rke2_agent[*].private_ip
}

output "load_balancer_dns" {
  description = "DNS name of load balancer"
  value       = aws_lb.rancher.dns_name
}

output "server_instance_ids" {
  description = "Instance IDs of server nodes"
  value       = aws_instance.rke2_server[*].id
}

output "agent_instance_ids" {
  description = "Instance IDs of agent nodes"
  value       = aws_instance.rke2_agent[*].id
}
