
output "vnet_ids"{
  value = {
    spoke-1   = azurerm_virtual_network.vnet-spoke-1.id
    spoke-2   = azurerm_virtual_network.vnet-spoke-2.id
  }   
}

output "vnet_names"{
  value = {
    spoke-1   = azurerm_virtual_network.vnet-spoke-1.name
    spoke-2   = azurerm_virtual_network.vnet-spoke-2.name
  }   
}

output "vnet_cidrs"{
  value = {
    spoke-1   = azurerm_virtual_network.vnet-spoke-1.address_space[0]
    spoke-2   = azurerm_virtual_network.vnet-spoke-2.address_space[0]
  }   
}

output "subnet_ids"{
  value = {
    spoke-1_subnet1   = azurerm_subnet.subnet-spoke-1-subnet1.id
    spoke-1_subnet2   = azurerm_subnet.subnet-spoke-1-subnet2.id
    spoke-2_subnet1   = azurerm_subnet.subnet-spoke-2-subnet1.id
    spoke-2_subnet2   = azurerm_subnet.subnet-spoke-2-subnet2.id
    spoke-1_rs        = azurerm_subnet.subnet-spoke-1-routeserver.id
    spoke-2_rs        = azurerm_subnet.subnet-spoke-2-routeserver.id
    spoke-1_vgw       = azurerm_subnet.subnet-spoke-1-vgw.id
    spoke-2_vgw       = azurerm_subnet.subnet-spoke-2-vgw.id
    spoke-1_pl        = azurerm_subnet.subnet-spoke-1-pl.id
    spoke-2_pl        = azurerm_subnet.subnet-spoke-2-pl.id
    spoke-1_pl-s      = azurerm_subnet.subnet-spoke-1-pl-s.id
    spoke-2_pl-s      = azurerm_subnet.subnet-spoke-2-pl-s.id
  }
}

output "subnet_names"{
  value = {
    spoke-1_subnet1   = azurerm_subnet.subnet-spoke-1-subnet1.name
    spoke-1_subnet2   = azurerm_subnet.subnet-spoke-1-subnet2.name
    spoke-2_subnet1   = azurerm_subnet.subnet-spoke-2-subnet1.name
    spoke-2_subnet2   = azurerm_subnet.subnet-spoke-2-subnet2.name
  }
}

output "subnet_cidrs"{
  value = {
    spoke-1_subnet1   = azurerm_subnet.subnet-spoke-1-subnet1.address_prefixes[0]
    spoke-1_subnet2   = azurerm_subnet.subnet-spoke-1-subnet2.address_prefixes[0]
    spoke-2_subnet1   = azurerm_subnet.subnet-spoke-2-subnet1.address_prefixes[0]
    spoke-2_subnet2   = azurerm_subnet.subnet-spoke-2-subnet2.address_prefixes[0]
    spoke-1_pl        = azurerm_subnet.subnet-spoke-1-pl.address_prefixes[0]
    spoke-2_pl        = azurerm_subnet.subnet-spoke-2-pl.address_prefixes[0]
  }
}

output "nsg_ids"{
  value = {
    spoke-1 = azurerm_network_security_group.nsg-hub-spoke.id
    spoke-2 = azurerm_network_security_group.nsg-hub-spoke.id
  }
}

output "ni_ids" {
  value = {
    spoke-1_subnet1 = azurerm_network_interface.ni-spoke-1-vm-1.id
    spoke-1_subnet2 = azurerm_network_interface.ni-spoke-1-vm-2.id
    spoke-2_subnet1 = azurerm_network_interface.ni-spoke-2-vm-1.id
    spoke-2_subnet2 = azurerm_network_interface.ni-spoke-2-vm-2.id
  }
}

output "ni_ips" {
  value = {
    spoke-1_subnet1 = azurerm_network_interface.ni-spoke-1-vm-1.private_ip_addresses[0]
    spoke-1_subnet2 = azurerm_network_interface.ni-spoke-1-vm-2.private_ip_addresses[0]
    spoke-2_subnet1 = azurerm_network_interface.ni-spoke-2-vm-1.private_ip_addresses[0]
    spoke-2_subnet2 = azurerm_network_interface.ni-spoke-2-vm-2.private_ip_addresses[0]
  }
}