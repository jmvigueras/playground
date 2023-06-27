#--------------------------------------------------------------------------------
# Create route table bastion
#--------------------------------------------------------------------------------
/*
// Route-table definition
resource "azurerm_route_table" "rt-bastion" {
  name                = "${var.prefix}-rt-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  disable_bgp_route_propagation = false

  route {
    name                   = "rfc1918-1"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fgt_1_ni_private_ip
  }
  route {
    name                   = "rfc1918-2"
    address_prefix         = "192.168.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fgt_1_ni_private_ip
  }
  route {
    name                   = "rfc1918-3"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fgt_1_ni_private_ip
  }
}

// Route table association
resource "azurerm_subnet_route_table_association" "rta-spoke-1-subnet-1" {
  subnet_id      = azurerm_subnet.subnet-bastion.id
  route_table_id = azurerm_route_table.rt-bastion.id
}
*/