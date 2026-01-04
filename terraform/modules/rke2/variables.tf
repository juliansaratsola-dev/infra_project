variable "environment" {
  description = "Environment name"
  type        = string
}

variable "server_ips" {
  description = "List of RKE2 server node IPs"
  type        = list(string)
}

variable "agent_ips" {
  description = "List of RKE2 agent node IPs"
  type        = list(string)
}

variable "cluster_token" {
  description = "RKE2 cluster token"
  type        = string
  sensitive   = true
}

variable "rancher_version" {
  description = "Rancher version to install"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "rancher_hostname" {
  description = "Hostname for Rancher UI"
  type        = string
  default     = "rancher.local"
}
