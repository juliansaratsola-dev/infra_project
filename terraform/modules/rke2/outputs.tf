output "rke2_server_config_path" {
  description = "Path to RKE2 server config file"
  value       = local_file.rke2_server_config.filename
}

output "rke2_agent_config_path" {
  description = "Path to RKE2 agent config file"
  value       = local_file.rke2_agent_config.filename
}

output "rancher_values_path" {
  description = "Path to Rancher values file"
  value       = local_file.rancher_values.filename
}

output "inventory_path" {
  description = "Path to installation inventory"
  value       = local_file.inventory.filename
}
