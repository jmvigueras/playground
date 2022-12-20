output "fgt-site-spoke" {
  value = {
    admin        = var.adminusername
    pass         = var.adminpassword
    api_key      = module.fgt-site-ha.fgt-spoke["api_key"]
    active_mgmt  = "https://${module.vnet-fgt.fgt-active-mgmt-ip}:${var.admin_port}"
    passive_mgmt = "https://${module.vnet-fgt.fgt-passive-mgmt-ip}:${var.admin_port}"
    active_ssh   = "ssh -i ssh-key.pem ${var.adminusername}@${module.vnet-fgt.fgt-active-mgmt-ip}"
    passive_ssh  = "ssh -i ssh-key.pem ${var.adminusername}@${module.vnet-fgt.fgt-passive-mgmt-ip}"
  }
}

output "bastion-vm" {
  value = {
    ssh_access = "ssh -i ssh-key.pem ${var.adminusername}@${module.vnet-fgt.bastion-public-ip_ip}"
    private_ip = cidrhost(module.vnet-fgt.subnet_cidrs["bastion"], 10)
    udr_route_name = azurerm_route_table.rt-bastion.name
  }
}