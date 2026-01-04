# Variables for the infrastructure project

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "vet-infra"
}

# Network variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# Compute variables
variable "rke2_server_count" {
  description = "Number of RKE2 server nodes"
  type        = number
  default     = 1
}

variable "rke2_agent_count" {
  description = "Number of RKE2 agent nodes"
  type        = number
  default     = 2
}

variable "instance_type_server" {
  description = "Instance type for RKE2 server nodes"
  type        = string
  default     = "t3.medium"
}

variable "instance_type_agent" {
  description = "Instance type for RKE2 agent nodes"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into instances"
  type        = string
  default     = "0.0.0.0/0"  # Restrict this in production
}

# RKE2 variables
variable "rke2_cluster_token" {
  description = "Token for RKE2 cluster authentication"
  type        = string
  sensitive   = true
}

variable "rancher_version" {
  description = "Version of Rancher to install"
  type        = string
  default     = "2.7.9"
}
