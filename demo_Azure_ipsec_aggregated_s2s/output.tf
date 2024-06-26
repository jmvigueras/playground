
#-----------------------------------------------------------------------------------------------------
# Region 1 - HUBs
#-----------------------------------------------------------------------------------------------------
// HUB Azure core
output "r1_hub_azure_core" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    active_mgmt  = "https://${module.r1_hub_azure_core_vnet.fgt-active-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.r1_hub_azure_core_vnet.fgt-passive-mgmt-ip}:${local.admin_port}"
  }
}
// VM HUB Azure core
output "r1_hub_vnet_spoke_vm" {
  value = module.r1_hub_vnet_spoke_vm.*.vm
}
// Azure ON-PREM
output "r1_hub_on_prem" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    active_mgmt  = "https://${module.r1_hub_on_prem_vnet.fgt-active-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.r1_hub_on_prem_vnet.fgt-passive-mgmt-ip}:${local.admin_port}"
  }
}
// VM ON-PREM
output "r1_on_prem_vnet_spoke_vm" {
  value = module.r1_on_prem_vnet_spoke_vm.*.vm
}


/*
// FAZ
output "r1_faz" {
  value = {
    faz_mgmt = "https://${module.r1_faz.faz_public_ip}"
    faz_user = local.admin_username
    faz_pass = local.admin_password
  }
}
// FMG
output "r1_fmg" {
  value = {
    fmg_mgmt = "https://${module.r1_fmg.fmg_public_ip}"
    fmg_user = local.admin_username
    fmg_pass = local.admin_password
  }
}
#-----------------------------------------------------------------------------------------------------
# Region 2 - HUBs
#-----------------------------------------------------------------------------------------------------
// HUB Azure
output "r2_hub_azure_core" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    active_mgmt  = "https://${module.r2_hub_azure_core_vnet.fgt-active-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.r2_hub_azure_core_vnet.fgt-passive-mgmt-ip}:${local.admin_port}"
  }
}
// VM HUB Azure
output "r2_hub_vnet_spoke_vm" {
  value = module.r2_hub_vnet_spoke_vm.*.vm
}
#-----------------------------------------------------------------------------------------------------
# Region 3 - HUBs
#-----------------------------------------------------------------------------------------------------
// HUB Azure
output "r3_hub_azure_core" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    active_mgmt  = "https://${module.r3_hub_azure_core_vnet.fgt-active-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.r3_hub_azure_core_vnet.fgt-passive-mgmt-ip}:${local.admin_port}"
  }
}
// VM HUB Azure
output "r3_hub_vnet_spoke_vm" {
  value = module.r3_hub_vnet_spoke_vm.*.vm
}
#-----------------------------------------------------------------------------------------------------
# Region 1 - Spokes
#-----------------------------------------------------------------------------------------------------
// Spokes
output "r1_fgt_spoke" {
  value = {
    username   = "admin"
    pass       = local.admin_password
    fgt-1_mgmt = module.r1_spoke_vnet.*.fgt-active-mgmt-ip
  }
}
// VM spoke
output "r1_spoke_vnet_vm" {
  value = module.r1_spoke_vnet_vm.*.vm
}
*/