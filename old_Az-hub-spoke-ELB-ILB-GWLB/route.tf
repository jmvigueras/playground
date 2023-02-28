######################################################
# Create route servers
######################################################
module "rs-spoke-1" {
    source = "./modules/routeserver"

    prefix                = var.prefix
    location              = var.location
    resourcegroup_name    = azurerm_resource_group.rg.name

    vnet_name   = module.vnet-spoke.vnet_names["spoke-1"]
    subnet_id   = module.vnet-spoke.subnet_ids["spoke-1_rs"]

    fgt_bgp-asn  = var.hub["bgp-asn"]
    fgt1_peer-ip = module.vnet-fgt.fgt-active-ni_ips["port3"]
    fgt2_peer-ip = module.vnet-fgt.fgt-passive-ni_ips["port3"]
}

module "rs-spoke-2" {
    source = "./modules/routeserver"

    prefix                = var.prefix
    location              = var.location
    resourcegroup_name    = azurerm_resource_group.rg.name

    vnet_name   = module.vnet-spoke.vnet_names["spoke-2"]
    subnet_id   = module.vnet-spoke.subnet_ids["spoke-2_rs"]

    fgt_bgp-asn  = var.hub["bgp-asn"]
    fgt1_peer-ip = module.vnet-fgt.fgt-active-ni_ips["port3"]
    fgt2_peer-ip = module.vnet-fgt.fgt-passive-ni_ips["port3"]
}

######################################################
# Create table routes spokes
######################################################

// Route-table definition
resource "azurerm_route_table" "rt-spoke-1" {
  name                = "${var.prefix}-rt-spoke-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  disable_bgp_route_propagation = false

  route {
    name                   = "r-subnet-1"
    address_prefix         = module.vnet-spoke.subnet_cidrs["spoke-1_subnet1"]
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.lb.ilb_private-ip
  }
  route {
    name                   = "r-subnet-2"
    address_prefix         = module.vnet-spoke.subnet_cidrs["spoke-1_subnet2"]
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.lb.ilb_private-ip
  }
  route {
    name                   = "r-subnet-pl"
    address_prefix         = module.vnet-spoke.subnet_cidrs["spoke-1_pl"]
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.lb.ilb_private-ip
  }
}

// Route table association
resource "azurerm_subnet_route_table_association" "rta-spoke-1-subnet-1" {
  subnet_id      = module.vnet-spoke.subnet_ids["spoke-1_subnet1"]
  route_table_id = azurerm_route_table.rt-spoke-1.id
}

resource "azurerm_subnet_route_table_association" "rta-spoke-1-subnet-2" {
  subnet_id      = module.vnet-spoke.subnet_ids["spoke-1_subnet2"]
  route_table_id = azurerm_route_table.rt-spoke-1.id
}

resource "azurerm_subnet_route_table_association" "rta-spoke-1-pl" {
  subnet_id      = module.vnet-spoke.subnet_ids["spoke-1_pl"]
  route_table_id = azurerm_route_table.rt-spoke-1.id
}

######################################################
# Create peering
######################################################

resource "azurerm_virtual_network_peering" "peerSpoke1toFGT-1" {
  name                      = "${var.prefix}-peer-spoke-1-to-FGT-1"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.vnet-spoke.vnet_names["spoke-1"]
  remote_virtual_network_id = module.vnet-fgt.vnet_ids["vnet-fgt"]
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peerSpoke1toFGT-2" {
  name                      = "${var.prefix}-peer-spoke-1-to-FGT-2"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.vnet-fgt.vnet_names["vnet-fgt"]
  remote_virtual_network_id = module.vnet-spoke.vnet_ids["spoke-1"]
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peerSpoke2toFGT-1" {
  name                      = "${var.prefix}-peer-spoke-2-to-FGT-1"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.vnet-spoke.vnet_names["spoke-2"]
  remote_virtual_network_id = module.vnet-fgt.vnet_ids["vnet-fgt"]
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peerSpoke2toFGT-2" {
  name                      = "${var.prefix}-peer-spoke-2-to-FGT-2"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.vnet-fgt.vnet_names["vnet-fgt"]
  remote_virtual_network_id = module.vnet-spoke.vnet_ids["spoke-2"]
  allow_forwarded_traffic   = true
}
