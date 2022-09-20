
output "vnet_ids"{
  value = {
    "spoke-1" = azurerm_virtual_network.vnet-spoke-1.id
    "spoke-2" = azurerm_virtual_network.vnet-spoke-2.id
  }   
}

output "vnet_names"{
  value = {
    "spoke-1" = azurerm_virtual_network.vnet-spoke-1.name
    "spoke-2" = azurerm_virtual_network.vnet-spoke-2.name
  }   
}

output "subnet-spoke_ids"{
  value = {
    "spoke-1-vm"        = azurerm_subnet.subnet-spoke-1-vm.id
    "spoke-2-vm"        = azurerm_subnet.subnet-spoke-2-vm.id
    "spoke-1-vm-rs"     = azurerm_subnet.subnet-spoke-1-route-server.id
    "spoke-2-vm-rs"     = azurerm_subnet.subnet-spoke-2-route-server.id
    "spoke-1-vm-vgw"    = azurerm_subnet.subnet-spoke-1-vgw.id
    "spoke-2-vm-vgw"    = azurerm_subnet.subnet-spoke-2-vgw.id
  }
}

output "subnet-spoke_names"{
  value = {
    "spoke-1-vm" = azurerm_subnet.subnet-spoke-1-vm.name
    "spoke-2-vm" = azurerm_subnet.subnet-spoke-2-vm.name
  }
}

output "subnet-spoke_nets"{
  value = {
    "spoke-1-vm" = azurerm_subnet.subnet-spoke-1-vm.address_prefixes[0]
    "spoke-2-vm" = azurerm_subnet.subnet-spoke-2-vm.address_prefixes[0]
  }
}

output "nsg_ids"{
  value = {
    "spoke-1-vm" = azurerm_network_security_group.nsg-spoke-vm.id
    "spoke-2-vm" = azurerm_network_security_group.nsg-spoke-vm.id
  }
}

output "ni-spoke-vm_ids" {
  value = {
    "spoke-1-vm" = azurerm_network_interface.ni-spoke-1-vm.id
    "spoke-2-vm" = azurerm_network_interface.ni-spoke-2-vm.id
  }
}