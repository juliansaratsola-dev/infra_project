output "instance_ip" {
  value = aws_instance.example.public_ip
}

output "instance_id" {
  value = aws_instance.example.id
}

output "vpc_id" {
  value = aws_vpc.example.id
}

output "service_ip" {
  value = kubernetes_service.node_server_service.status[0].load_balancer.ingress[0].ip
}