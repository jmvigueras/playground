// Table routes Region

// Route-table definition
resource "azurerm_route_table" "rt-vnet-fgt-private" {
  name                = "${var.prefix}-rt-vnet-fgt-private"
  location            = var.regiona
  resource_group_name = azurerm_resource_group.rg-regiona.name

  disable_bgp_route_propagation = true
}

resource "azurerm_route_table" "rt-vnet-spoke-vm" {
  name                = "${var.prefix}-rt-vnet-spoke-vm"
  location            = var.regiona
  resource_group_name = azurerm_resource_group.rg-regiona.name

  disable_bgp_route_propagation = true
}

// Routes definition 
resource "azurerm_route" "r-default-private" {
  name                   = "default"
  resource_group_name    = azurerm_resource_group.rg-regiona.name
  route_table_name       = azurerm_route_table.rt-vnet-fgt-private.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.vnet-fgt.fgt-active-ni_ips["port2"]
}

resource "azurerm_route" "r-default-vnet-spokes" {
  name                   = "default"
  resource_group_name    = azurerm_resource_group.rg-regiona.name
  route_table_name       = azurerm_route_table.rt-vnet-spoke-vm.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.vnet-fgt.fgt-active-ni_ips["port3"]
}

// Route table association
resource "azurerm_subnet_route_table_association" "rta-fgt-private" {
  subnet_id      = module.vnet-fgt.subnet-vnet-fgt_ids["private"]
  route_table_id = azurerm_route_table.rt-vnet-fgt-private.id
}

resource "azurerm_subnet_route_table_association" "rta-spoke-1-vm" {
  subnet_id      = module.vnet-spoke.subnet-spoke_ids["spoke-1-vm"]
  route_table_id = azurerm_route_table.rt-vnet-spoke-vm.id
}

resource "azurerm_subnet_route_table_association" "rta-spoke-2-vm" {
  subnet_id      = module.vnet-spoke.subnet-spoke_ids["spoke-2-vm"]
  route_table_id = azurerm_route_table.rt-vnet-spoke-vm.id
}

// Peering SpokeA with VPC Fortinet

resource "azurerm_virtual_network_peering" "peerSpoke1toFGT-1" {
  name                      = "${var.prefix}-peer-spoke-1-to-FGT-1"
  resource_group_name       = azurerm_resource_group.rg-regiona.name
  virtual_network_name      = module.vnet-spoke.vnet_names["spoke-1"]
  remote_virtual_network_id = module.vnet-fgt.vnet_ids["vnet-fgt"]
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peerSpoke1toFGT-2" {
  name                      = "${var.prefix}-peer-spoke-1-to-FGT-2"
  resource_group_name       = azurerm_resource_group.rg-regiona.name
  virtual_network_name      = module.vnet-fgt.vnet_names["vnet-fgt"]
  remote_virtual_network_id = module.vnet-spoke.vnet_ids["spoke-1"]
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peerSpoke2toFGT-1" {
  name                      = "${var.prefix}-peer-spoke-2-to-FGT-1"
  resource_group_name       = azurerm_resource_group.rg-regiona.name
  virtual_network_name      = module.vnet-spoke.vnet_names["spoke-2"]
  remote_virtual_network_id = module.vnet-fgt.vnet_ids["vnet-fgt"]
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peerSpoke2toFGT-2" {
  name                      = "${var.prefix}-peer-spoke-2-to-FGT-2"
  resource_group_name       = azurerm_resource_group.rg-regiona.name
  virtual_network_name      = module.vnet-fgt.vnet_names["vnet-fgt"]
  remote_virtual_network_id = module.vnet-spoke.vnet_ids["spoke-2"]
  allow_forwarded_traffic   = true
}
