output "hub-fgt-active-mgmt-url"{
  value = "https://${module.vnet-fgt.fgt-active-mgmt-ip}:${var.admin_port}"
}

output "hub-fgt-passive-mgmt-url"{
  value = "https://${module.vnet-fgt.fgt-passive-mgmt-ip}:${var.admin_port}"
}

output "hub-cluster-public-ip_ip"{
  value = module.vnet-fgt.cluster-public-ip_ip
}

output "TestVM-spoke-1-ip"{
  value = azurerm_network_interface.ni-vm-spoke-1.private_ip_address
}

output "TestVM-spoke-2-ip"{
  value = azurerm_network_interface.ni-vm-spoke-2.private_ip_address
}

output "Username" {
  value = var.adminusername
}

output "Password" {
  value = var.adminpassword
}

output "advpn_ipsec-psk-key" {
  value = var.advpn-ipsec-psk
}

output "api_key" {
  value = module.fgt-ha.api_key
}