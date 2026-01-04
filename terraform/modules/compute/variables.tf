variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "rke2_server_count" {
  description = "Number of RKE2 server nodes"
  type        = number
}

variable "rke2_agent_count" {
  description = "Number of RKE2 agent nodes"
  type        = number
}

variable "instance_type_server" {
  description = "Instance type for server nodes"
  type        = string
}

variable "instance_type_agent" {
  description = "Instance type for agent nodes"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH"
  type        = string
}

variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate for load balancer"
  type        = string
  default     = ""
}
