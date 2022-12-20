// Create table route and routes for VM bastion
resource "azurerm_route_table" "rt-bastion" {
  name                = "${var.prefix}-rt-bastion"
  location            = var.location
  resource_group_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
}

resource "azurerm_route" "r-RFC1918-bastion-1" {
  depends_on             = [module.fgt-site-ha]
  name                   = "RFC1918-bastion-1"
  resource_group_name    = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  route_table_name       = azurerm_route_table.rt-bastion.name
  address_prefix         = "10.0.0.0/8"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.vnet-fgt.fgt-active-ni_ips["port3"]
}

resource "azurerm_route" "r-RFC1918-bastion-2" {
  depends_on             = [module.fgt-site-ha]
  name                   = "RFC1918-bastion-2"
  resource_group_name    = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  route_table_name       = azurerm_route_table.rt-bastion.name
  address_prefix         = "172.16.0.0/12"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.vnet-fgt.fgt-active-ni_ips["port3"]
}

resource "azurerm_route" "r-RFC1918-bastion-3" {
  depends_on             = [module.fgt-site-ha]
  name                   = "RFC1918-bastion-3"
  resource_group_name    = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  route_table_name       = azurerm_route_table.rt-bastion.name
  address_prefix         = "192.168.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.vnet-fgt.fgt-active-ni_ips["port3"]
}

// Route table association
resource "azurerm_subnet_route_table_association" "bastion-rt-association" {
  subnet_id      = module.vnet-fgt.subnet_ids["bastion"]
  route_table_id = azurerm_route_table.rt-bastion.id
}



