output "fgt_config" {
  value = data.template_file.fgt.rendered
}

output "vpn_psk" {
  value = var.hub[0]["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hub[0]["vpn_psk"]
}

output "api_key" {
  value = var.api_key == null ? random_string.api_key.result : var.api_key
}

