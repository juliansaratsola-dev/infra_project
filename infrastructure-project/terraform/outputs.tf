output "instance_ip" {
  value = aws_instance.example.public_ip
}

output "instance_id" {
  value = aws_instance.example.id
}

output "vpc_id" {
  value = aws_vpc.example.id
}