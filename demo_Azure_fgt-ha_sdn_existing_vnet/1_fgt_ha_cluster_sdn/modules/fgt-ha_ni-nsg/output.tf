output "fgt-active-mgmt-ip" {
  value = azurerm_public_ip.active-mgmt-ip.ip_address
}

output "fgt-passive-mgmt-ip" {
  value = azurerm_public_ip.passive-mgmt-ip.ip_address
}

output "fgt-active-public-ip" {
  value = azurerm_public_ip.active-public-ip-1.ip_address
}

output "fgt-active-public-name" {
  value = azurerm_public_ip.active-public-ip-1.name
}

output "fgt-active-public-ip-2" {
  value = azurerm_public_ip.active-public-ip-2.ip_address
}

output "fgt-active-public-name-2" {
  value = azurerm_public_ip.active-public-ip-2.name
}

output "fgt-active-ni_ids" {
  value = {
    mgmt    = azurerm_network_interface.ni-active-mgmt.id
    public  = azurerm_network_interface.ni-active-public.id
    private = azurerm_network_interface.ni-active-private.id
  }
}

output "fgt-active-ni_names" {
  value = {
    mgmt    = azurerm_network_interface.ni-active-mgmt.name
    public  = azurerm_network_interface.ni-active-public.name
    private = azurerm_network_interface.ni-active-private.name
  }
}

output "fgt-active-ni_ips" {
  value = {
    mgmt     = local.fgt-1_ni_mgmt_ip
    public   = local.fgt-1_ni_public_ip_1
    public_2 = local.fgt-1_ni_public_ip_2
    private  = local.fgt-1_ni_private_ip
  }
}

output "fgt-passive-ni_ids" {
  value = {
    mgmt    = azurerm_network_interface.ni-passive-mgmt.id
    public  = azurerm_network_interface.ni-passive-public.id
    private = azurerm_network_interface.ni-passive-private.id
  }
}

output "fgt-passive-ni_names" {
  value = {
    mgmt    = azurerm_network_interface.ni-passive-mgmt.name
    public  = azurerm_network_interface.ni-passive-public.name
    private = azurerm_network_interface.ni-passive-private.name
  }
}

output "fgt-passive-ni_ips" {
  value = {
    mgmt     = local.fgt-2_ni_mgmt_ip
    public   = local.fgt-2_ni_public_ip_1
    public_2 = local.fgt-2_ni_public_ip_2
    private  = local.fgt-2_ni_private_ip
  }
}

output "nsg_ids" {
  value = {
    mgmt    = azurerm_network_security_group.nsg-mgmt-ha.id
    public  = azurerm_network_security_group.nsg-public.id
    private = azurerm_network_security_group.nsg-private.id
    protected = azurerm_network_security_group.nsg_protected_admin_cidr.id
    //  protected_default = azurerm_network_security_group.nsg_protected_default.id
    //  public_default  = azurerm_network_security_group.nsg-public-default.id
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