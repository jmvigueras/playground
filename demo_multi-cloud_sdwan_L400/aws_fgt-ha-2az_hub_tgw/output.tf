# Output
output "fgt_hub" {
  value = {
    fgt-1_mgmt   = "https://${module.fgt_hub.fgt_active_eip_mgmt}:${local.admin_port}"
    fgt-2_mgmt   = "https://${module.fgt_hub.fgt_passive_eip_mgmt}:${local.admin_port}"
    fgt-1_public = module.fgt_hub.fgt_active_eip_public
    fgt-2_public = module.fgt_hub.fgt_passive_eip_public
    username     = "admin"
    fgt-1_pass   = module.fgt_hub.fgt_active_id
    fgt-2_pass   = module.fgt_hub.fgt_passive_id
    vpn_psk      = module.fgt_hub_config.vpn_psk
    admin_cidr   = "${chomp(data.http.my-public-ip.response_body)}/32"
    api_key      = module.fgt_hub_config.api_key
  }
}

output "vm_tgw_hub_az1" {
  value = module.vm_tgw_hub_az1.*.vm
}
output "vm_tgw_hub_az2" {
  value = module.vm_tgw_hub_az2.*.vm
}

output "hubs" {
  value = local.hubs
}

output "faz" {
  value = {
    public_mgmt  = "https://${module.faz.eip_public}"
    private_ip = module.faz.ni_ips["private"]
    admin_user = "admin"
    admin_pass  = module.faz.id
  }
}

output "fmg" {
  value = {
    public_mgmt  = "https://${module.fmg.eip_public}"
    private_ip = module.fmg.ni_ips["private"]
    admin_user = "admin"
    admin_pass  = module.fmg.id
  }
}