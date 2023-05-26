# Output
output "fgt_hub_it" {
  value = {
    fgt-1_mgmt   = "https://${module.fgt_hub_it.fgt_active_eip_mgmt}:${local.admin_port}"
    fgt-2_mgmt   = "https://${module.fgt_hub_it.fgt_passive_eip_mgmt}:${local.admin_port}"
    fgt-1_public = module.fgt_hub_it.fgt_active_eip_public
    fgt-2_public = module.fgt_hub_it.fgt_passive_eip_public
    username     = "admin"
    fgt-1_pass   = module.fgt_hub_it.fgt_active_id
    fgt-2_pass   = module.fgt_hub_it.fgt_passive_id
    vpn_psk      = module.fgt_hub_it_config.vpn_psk
    admin_cidr   = "${chomp(data.http.my-public-ip.response_body)}/32"
    api_key      = module.fgt_hub_it_config.api_key
  }
}
output "fgt_hub_ot" {
  value = {
    fgt-1_mgmt   = "https://${module.fgt_hub_ot.fgt_active_eip_mgmt}:${local.admin_port}"
    fgt-2_mgmt   = "https://${module.fgt_hub_ot.fgt_passive_eip_mgmt}:${local.admin_port}"
    fgt-1_public = module.fgt_hub_ot.fgt_active_eip_public
    fgt-2_public = module.fgt_hub_ot.fgt_passive_eip_public
    username     = "admin"
    fgt-1_pass   = module.fgt_hub_ot.fgt_active_id
    fgt-2_pass   = module.fgt_hub_ot.fgt_passive_id
    vpn_psk      = module.fgt_hub_ot_config.vpn_psk
    admin_cidr   = "${chomp(data.http.my-public-ip.response_body)}/32"
    api_key      = module.fgt_hub_ot_config.api_key
  }
}
output "fgt_ot_box" {
  value = {
    username   = "admin"
    fgt-1_mgmt = join(",", [for i in module.fgt_ot_box.*.fgt_active_eip_mgmt : i])
    fgt-1_pass = join(",", [for i in module.fgt_ot_box.*.fgt_active_id : i])
    admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"
    api_key    = join(",", [for i in module.fgt_ot_box_config.*.api_key : i])
  }
}
output "vm_tgw_hub_it" {
  value = module.vm_tgw_hub_it.*.vm
}
output "vm_fgw_hub_ot" {
  value = module.vm_tgw_hub_ot.*.vm
}
output "vm_fgt_ot_box" {
  value = module.vm_fgt_ot_box.*.vm
}