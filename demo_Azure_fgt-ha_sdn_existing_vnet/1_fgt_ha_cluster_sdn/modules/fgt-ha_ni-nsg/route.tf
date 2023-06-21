#--------------------------------------------------------------------------------
# Create route table protected
#--------------------------------------------------------------------------------
// Route-table definition
resource "azurerm_route_table" "rt-protected" {
  name                = "${var.prefix}-rt-protected"
  location            = var.location
  resource_group_name = var.resource_group_name

  disable_bgp_route_propagation = false

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fgt-1_ni_private_ip
  }
}

// Route table association
resource "azurerm_subnet_route_table_association" "rta-protected" {
  subnet_id      = var.subnet_ids["protected"]
  route_table_id = azurerm_route_table.rt-protected.id
}

