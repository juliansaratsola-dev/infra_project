output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "rke2_security_group_id" {
  description = "ID of RKE2 nodes security group"
  value       = aws_security_group.rke2_nodes.id
}

output "lb_security_group_id" {
  description = "ID of load balancer security group"
  value       = aws_security_group.lb.id
}
