//  Network Security Group

resource "azurerm_network_security_group" "nsg-fgt-site" {
  name                = "${var.prefix}-nsg-fgt-site"
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_security_rule" "nsr-fgt-site-ingress-spoke" {
  name                        = "${var.prefix}-nsr-fgt-site-ingress-all"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resourcegroup_name
  network_security_group_name = azurerm_network_security_group.nsg-fgt-site.name
}

resource "azurerm_network_security_rule" "nsr-fgt-site-egress-spoke" {
  name                        = "${var.prefix}-nsr-fgt-site-egress-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resourcegroup_name
  network_security_group_name = azurerm_network_security_group.nsg-fgt-site.name
}


# Connect the security group to the network interfaces FGT active
resource "azurerm_network_interface_security_group_association" "activeport1nsg" {
  network_interface_id      = azurerm_network_interface.ni-site-port1.id
  network_security_group_id = azurerm_network_security_group.nsg-fgt-site.id
}

resource "azurerm_network_interface_security_group_association" "activeport2nsg" {
  network_interface_id      = azurerm_network_interface.ni-site-port2.id
  network_security_group_id = azurerm_network_security_group.nsg-fgt-site.id
}

resource "azurerm_network_interface_security_group_association" "activeport3nsg" {
  network_interface_id      = azurerm_network_interface.ni-site-port3.id
  network_security_group_id = azurerm_network_security_group.nsg-fgt-site.id
}
