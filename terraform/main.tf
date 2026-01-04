# Main Terraform configuration for RKE2 + Rancher infrastructure
# This configuration sets up the infrastructure for deploying the vet_app

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration for remote state (uncomment when ready)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "infra-project/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Provider configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "vet-infra"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# Network module - VPC, subnets, security groups
module "network" {
  source = "./modules/network"
  
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_name        = var.project_name
}

# Compute module - EC2 instances for RKE2 nodes
module "compute" {
  source = "./modules/compute"
  
  environment            = var.environment
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_subnet_ids     = module.network.private_subnet_ids
  rke2_server_count      = var.rke2_server_count
  rke2_agent_count       = var.rke2_agent_count
  instance_type_server   = var.instance_type_server
  instance_type_agent    = var.instance_type_agent
  key_name               = var.key_name
  project_name           = var.project_name
  allowed_ssh_cidr       = var.allowed_ssh_cidr
}

# RKE2 cluster configuration
module "rke2" {
  source = "./modules/rke2"
  
  environment       = var.environment
  server_ips        = module.compute.server_private_ips
  agent_ips         = module.compute.agent_private_ips
  cluster_token     = var.rke2_cluster_token
  rancher_version   = var.rancher_version
  project_name      = var.project_name
}
