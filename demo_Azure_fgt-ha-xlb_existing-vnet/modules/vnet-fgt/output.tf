output "fgt-1-mgmt-ip" {
  value = azurerm_public_ip.fgt-1-mgmt-ip.ip_address
}

output "fgt-2-mgmt-ip" {
  value = azurerm_public_ip.fgt-2-mgmt-ip.ip_address
}

output "fgt-1-ni_ids" {
  value = {
    mgmt    = azurerm_network_interface.ni-fgt-1-mgmt.id
    public  = azurerm_network_interface.ni-fgt-1-public.id
    private = azurerm_network_interface.ni-fgt-1-private.id
  }
}

output "fgt-1-ni_names" {
  value = {
    mgmt    = local.fgt-1_ni_mgmt_name
    public  = local.fgt-1_ni_public_name
    private = local.fgt-1_ni_private_name
  }
}

output "fgt-1-ni_ips" {
  value = {
    mgmt    = local.fgt-1_ni_mgmt_ip
    public  = local.fgt-1_ni_public_ip
    private = local.fgt-1_ni_private_ip
  }
}

output "fgt-2-ni_ids" {
  value = {
    mgmt    = azurerm_network_interface.ni-fgt-2-mgmt.id
    public  = azurerm_network_interface.ni-fgt-2-public.id
    private = azurerm_network_interface.ni-fgt-2-private.id
  }
}

output "fgt-2-ni_names" {
  value = {
    mgmt    = local.fgt-2_ni_mgmt_name
    public  = local.fgt-2_ni_public_name
    private = local.fgt-2_ni_private_name
  }
}

output "fgt-2-ni_ips" {
  value = {
    mgmt    = local.fgt-2_ni_mgmt_ip
    public  = local.fgt-2_ni_public_ip
    private = local.fgt-2_ni_private_ip
  }
}

output "subnet_cidrs" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.address_prefixes[0]
    public  = azurerm_subnet.subnet-public.address_prefixes[0]
    private = azurerm_subnet.subnet-private.address_prefixes[0]
  }
}

output "subnet_names" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.name
    public  = azurerm_subnet.subnet-public.name
    private = azurerm_subnet.subnet-private.name
  }
}

output "subnet_ids" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.id
    public  = azurerm_subnet.subnet-public.id
    private = azurerm_subnet.subnet-private.id
  }
}

output "nsg_ids" {
  value = {
    mgmt           = azurerm_network_security_group.nsg-mgmt-ha.id
    public         = azurerm_network_security_group.nsg-public.id
    private        = azurerm_network_security_group.nsg-private.id
    public_default = azurerm_network_security_group.nsg-public-default.id
  }
}