#-----------------------------------------------------------------------------------------------------
# HUB 1
#-----------------------------------------------------------------------------------------------------
output "r1_fgt_hub" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    api_key      = module.r1_fgt_hub_config.api_key
    active_mgmt  = "https://${module.r1_fgt_hub_vnet.fgt-active-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.r1_fgt_hub_vnet.fgt-passive-mgmt-ip}:${local.admin_port}"
    vpn_psk      = module.r1_fgt_hub_config.vpn_psk
  }
}

output "r1_hub_vnet_spoke_vm" {
  value = module.r1_hub_vnet_spoke_vm.vm
}
#-----------------------------------------------------------------------------------------------------
# HUB 2
#-----------------------------------------------------------------------------------------------------
output "r2_fgt_hub" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    api_key      = module.r2_fgt_hub_config.api_key
    active_mgmt  = "https://${module.r2_fgt_hub_vnet.fgt-active-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.r2_fgt_hub_vnet.fgt-passive-mgmt-ip}:${local.admin_port}"
    vpn_psk      = module.r2_fgt_hub_config.vpn_psk
  }
}

output "r2_hub_vnet_spoke_vm" {
  value = module.r2_hub_vnet_spoke_vm.vm
}

#-----------------------------------------------------------------------------------------------------
# Spokes
#-----------------------------------------------------------------------------------------------------
output "r1_fgt_spoke" {
  value = {
    username   = "admin"
    pass       = local.admin_password
    fgt-1_mgmt = module.r1_fgt_spoke_vnet.*.fgt-active-mgmt-ip
    admin_cidr = "${chomp(data.http.my-public-ip.body)}/32"
    api_key    = module.r1_fgt_spoke_config.*.api_key
  }
}

/*
output "r1_vm_sdwan-bastion" {
  value = module.r1_vm_sdwan-bastion.*.vm
}
*/

output "r1_spoke_vnet_vm" {
  value = module.r1_spoke_vnet_vm.*.vm
}