output "fgt_config_1" {
  value = data.template_file.fgt_active.rendered
}

output "fgt_config_2" {
  value = data.template_file.fgt_passive.rendered
}

output "vpn_psk" {
  value = var.hub["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hub["vpn_psk"]
}

output "api_key" {
  value = var.api_key == null ? random_string.api_key.result : var.api_key
}

output "fgsp_auto-config_secret" {
  value = random_string.fgsp_auto-config_secret.result
}


