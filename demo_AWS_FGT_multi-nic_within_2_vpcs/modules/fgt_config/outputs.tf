output "fgt_config" {
  description = "FortiGate configuration output"
  sensitive   = true
  value       = data.template_file.fgt.rendered
}

output "vpn_psk" {
  description = "VPN Pre-Shared Key (PSK)"
  sensitive   = true
  value       = var.hub[0]["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hub[0]["vpn_psk"]
}

output "api_key" {
  description = "API Key for FortiGate instance"
  sensitive   = true
  value       = var.api_key == null ? random_string.api_key.result : var.api_key
}


#-------------------------------
# Debugging 
#-------------------------------
/*
output "debugs" {
  value = {
    fgsp_peer_ips = local.fgsp_peer_ips
    fgcp_gw       = local.fgcp_gw
    fgsp_config   = data.template_file.config_fgsp.rendered
    auto_scale    = var.config_auto_scale ? data.template_file.config_auto_scale.rendered : ""
    fgt_config = data.template_file.fgt.rendered
  }
}
*/

