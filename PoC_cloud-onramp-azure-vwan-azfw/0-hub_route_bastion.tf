#-----------------------------------------------------------------------------
# Create necessary table route for access bastion VM from outsite
# - Create a table route for Bastion VM in FGT VNET
# - RFC1918 ranges will be accessible through fortigate
#-----------------------------------------------------------------------------
resource "azurerm_route_table" "hub_rt-bastion" {
  name                = "${var.prefix}-hub-rt-bastion"
  location            = var.location
  resource_group_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
}

resource "azurerm_route" "hub_r-RFC1918-bastion-1" {
  depends_on             = [module.hub_fgt]
  name                   = "RFC1918-bastion-1"
  resource_group_name    = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  route_table_name       = azurerm_route_table.hub_rt-bastion.name
  address_prefix         = "10.0.0.0/8"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.hub_vnet-fgt.fgt-active-ni_ips["port3"]
}

resource "azurerm_route" "hub_r-RFC1918-bastion-2" {
  depends_on             = [module.hub_fgt]
  name                   = "RFC1918-bastion-2"
  resource_group_name    = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  route_table_name       = azurerm_route_table.hub_rt-bastion.name
  address_prefix         = "172.16.0.0/12"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.hub_vnet-fgt.fgt-active-ni_ips["port3"]
}

resource "azurerm_route" "hub_r-RFC1918-bastion-3" {
  depends_on             = [module.hub_fgt]
  name                   = "RFC1918-bastion-3"
  resource_group_name    = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  route_table_name       = azurerm_route_table.hub_rt-bastion.name
  address_prefix         = "192.168.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.hub_vnet-fgt.fgt-active-ni_ips["port3"]
}

// Route table association
resource "azurerm_subnet_route_table_association" "hub_bastion-rt-association" {
  subnet_id      = module.hub_vnet-fgt.subnet_ids["bastion"]
  route_table_id = azurerm_route_table.hub_rt-bastion.id
}



