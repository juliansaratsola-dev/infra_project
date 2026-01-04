# RKE2 module - Configuration for RKE2 cluster setup

# This module provides configuration templates and outputs for RKE2 installation
# The actual installation is done via the scripts in the scripts/ directory

locals {
  rke2_server_config = templatefile("${path.module}/templates/rke2-server-config.yaml.tpl", {
    cluster_token = var.cluster_token
  })

  rke2_agent_config = templatefile("${path.module}/templates/rke2-agent-config.yaml.tpl", {
    server_ip     = var.server_ips[0]
    cluster_token = var.cluster_token
  })

  rancher_values = templatefile("${path.module}/templates/rancher-values.yaml.tpl", {
    rancher_version     = var.rancher_version
    hostname            = var.rancher_hostname
    bootstrap_password  = var.rancher_bootstrap_password
  })
}

# Output configurations for use in installation scripts
resource "local_file" "rke2_server_config" {
  content  = local.rke2_server_config
  filename = "${path.module}/generated/rke2-server-config.yaml"
}

resource "local_file" "rke2_agent_config" {
  content  = local.rke2_agent_config
  filename = "${path.module}/generated/rke2-agent-config.yaml"
}

resource "local_file" "rancher_values" {
  content  = local.rancher_values
  filename = "${path.module}/generated/rancher-values.yaml"
}

# Generate installation inventory
resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.yaml.tpl", {
    server_ips = var.server_ips
    agent_ips  = var.agent_ips
  })
  filename = "${path.module}/generated/inventory.yaml"
}
