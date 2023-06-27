
output "fgt-active-mgmt-ip" {
  value = azurerm_public_ip.active-mgmt-ip.ip_address
}

output "fgt-passive-mgmt-ip" {
  value = azurerm_public_ip.passive-mgmt-ip.ip_address
}

output "fgt-active-public-ip" {
  value = var.config_xlb ? "ExternalLB_FrontEnd" : azurerm_public_ip.active-public-ip[0].ip_address
}

output "fgt-active-public-name" {
  value = local.fgt_1_public_ip_name
}
output "fgt-passive-public-name" {
  value = local.fgt_2_public_ip_name
}

output "fgt-passive-public-ip" {
  value = var.config_xlb ? "ExternalLB_FrontEnd" : azurerm_public_ip.passive-public-ip[0].ip_address
}

output "vnet" {
  value = {
    name = azurerm_virtual_network.vnet-fgt.name
    id   = azurerm_virtual_network.vnet-fgt.id
  }
}

output "vnet_names" {
  value = {
    vnet-fgt = azurerm_virtual_network.vnet-fgt.name
  }
}

output "fgt-active-ni_ids" {
  value = {
    mgmt      = azurerm_network_interface.ni-active-mgmt.id
    public    = local.fgt_1_ni_public_id
    private   = azurerm_network_interface.ni-active-private.id
    public_1  = azurerm_network_interface.ni-active-public-1.id
  }
}

output "fgt-active-ni_names" {
  value = {
    mgmt      = local.fgt_1_ni_mgmt_name
    public    = local.fgt_1_ni_public_name
    private   = local.fgt_1_ni_private_name
    public_1  = local.fgt_1_ni_public_1_name
  }
}

output "fgt-active-ni_ips" {
  value = {
    mgmt      = local.fgt_1_ni_mgmt_ip
    public    = local.fgt_1_ni_public_ip
    private   = local.fgt_1_ni_private_ip
    public_1  = local.fgt_1_ni_public_1_ip
  }
}

output "fgt-passive-ni_ids" {
  value = {
    mgmt      = azurerm_network_interface.ni-passive-mgmt.id
    public    = local.fgt_2_ni_public_id
    private   = azurerm_network_interface.ni-passive-private.id
    public_1  = azurerm_network_interface.ni-passive-public-1.id
  }
}

output "fgt-passive-ni_names" {
  value = {
    mgmt      = local.fgt_2_ni_mgmt_name
    public    = local.fgt_2_ni_public_name
    private   = local.fgt_2_ni_private_name
    public_1  = local.fgt_2_ni_public_1_name
  }
}

output "fgt-passive-ni_ips" {
  value = {
    mgmt      = local.fgt_2_ni_mgmt_ip
    public    = local.fgt_2_ni_public_ip
    private   = local.fgt_2_ni_private_ip
    public_1  = local.fgt_2_ni_public_1_ip
  }
}

output "subnet_cidrs" {
  value = {
    mgmt     = local.subnet_mgmt_cidr
    public   = local.subnet_public_cidr
    private  = local.subnet_private_cidr
    public_1 = local.subnet_public_1_cidr
  }
}

output "subnet_names" {
  value = {
    mgmt     = azurerm_subnet.subnet-hamgmt.name
    public   = azurerm_subnet.subnet-public.name
    private  = azurerm_subnet.subnet-private.name
    //vgw     = azurerm_subnet.subnet-vgw.name
    //rs      = azurerm_subnet.subnet-routeserver.name
    //bastion = azurerm_subnet.subnet-bastion.name
    public_1 = azurerm_subnet.subnet-public-1.name
  }
}

output "subnet_ids" {
  value = {
    mgmt     = azurerm_subnet.subnet-hamgmt.id
    public   = azurerm_subnet.subnet-public.id
    private  = azurerm_subnet.subnet-private.id
    //vgw     = azurerm_subnet.subnet-vgw.id
    //rs      = azurerm_subnet.subnet-routeserver.id
    //bastion = azurerm_subnet.subnet-bastion.id
    public_1 = azurerm_subnet.subnet-public-1.id
  }
}

output "nsg_ids" {
  value = {
    mgmt            = azurerm_network_security_group.nsg-mgmt-ha.id
    public          = azurerm_network_security_group.nsg-public.id
    private         = azurerm_network_security_group.nsg-private.id
    //bastion         = azurerm_network_security_group.nsg_bastion_admin_cidr.id
    //bastion_default = azurerm_network_security_group.nsg_bastion_default.id
    public_default  = azurerm_network_security_group.nsg-public-default.id
  }
}

output "nsg-public_id" {
  value = azurerm_network_security_group.nsg-public.id
}

output "nsg-private_id" {
  value = azurerm_network_security_group.nsg-private.id
}

output "nsg-mgmt-ha_id" {
  value = azurerm_network_security_group.nsg-mgmt-ha.id
}