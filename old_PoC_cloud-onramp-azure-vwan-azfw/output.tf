output "onramp_fgt" {
  value = {
    admin        = var.adminusername
    pass         = var.adminpassword
    api_key      = module.onramp_fgt.fgt-spoke["api_key"]
    active_mgmt  = "https://${module.onramp_vnet-fgt.fgt-active-mgmt-ip}:${var.admin_port}"
    passive_mgmt = "https://${module.onramp_vnet-fgt.fgt-passive-mgmt-ip}:${var.admin_port}"
    active_ssh   = "ssh -i ssh-key.pem ${var.adminusername}@${module.onramp_vnet-fgt.fgt-active-mgmt-ip}"
    passive_ssh  = "ssh -i ssh-key.pem ${var.adminusername}@${module.onramp_vnet-fgt.fgt-passive-mgmt-ip}"
  }
}

output "onramp_vm" {
  value = {
    ssh_access     = "ssh -i ssh-key.pem ${var.adminusername}@${module.onramp_vnet-fgt.bastion-public-ip_ip}"
    private_ip     = cidrhost(module.onramp_vnet-fgt.subnet_cidrs["bastion"], 10)
    udr_route_name = azurerm_route_table.onramp_rt-bastion.name
  }
}

output "vwan_vm_ips" {
  value = {
    vnet1-vm = module.vwan_vnet-spoke.ni_ips["subnet1"][0][0]
    vnet2-vm = module.vwan_vnet-spoke.ni_ips["subnet1"][1][0]
  }
}

output "hub_fgt" {
  value = {
    admin        = var.adminusername
    pass         = var.adminpassword
    api_key      = module.hub_fgt.fgt["api_key"]
    advpn-psk    = module.hub_fgt.hub["advpn-psk"]
    active_mgmt  = "https://${module.hub_vnet-fgt.fgt-active-mgmt-ip}:${var.admin_port}"
    passive_mgmt = "https://${module.hub_vnet-fgt.fgt-passive-mgmt-ip}:${var.admin_port}"
    active_ssh   = "ssh -i ssh-key.pem ${var.adminusername}@${module.hub_vnet-fgt.fgt-active-mgmt-ip}"
    passive_ssh  = "ssh -i ssh-key.pem ${var.adminusername}@${module.hub_vnet-fgt.fgt-passive-mgmt-ip}"
  }
}

output "hub_vm" {
  value = {
    ssh_access     = "ssh -i ssh-key.pem ${var.adminusername}@${module.hub_vnet-fgt.bastion-public-ip_ip}"
    private_ip     = cidrhost(module.hub_vnet-fgt.subnet_cidrs["bastion"], 10)
    udr_route_name = azurerm_route_table.hub_rt-bastion.name
  }
}



