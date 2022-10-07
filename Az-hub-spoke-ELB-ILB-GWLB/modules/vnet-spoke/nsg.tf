//  Network Security Group

resource "azurerm_network_security_group" "nsg-hub-spoke" {
  name                = "${var.prefix}-nsg-hub-spokefgt-vm"
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_security_rule" "nsr-hub-ingress-spoke" {
  name                        = "${var.prefix}-nsr-hub-ingress-all"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resourcegroup_name
  network_security_group_name = azurerm_network_security_group.nsg-hub-spoke.name
}

resource "azurerm_network_security_rule" "nsr-hub-egress-spoke" {
  name                        = "${var.prefix}-nsr-hub-egress-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resourcegroup_name
  network_security_group_name = azurerm_network_security_group.nsg-hub-spoke.name
}


# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "ni-spoke-1-vm-1-nsg" {
  network_interface_id      = azurerm_network_interface.ni-spoke-1-vm-1.id
  network_security_group_id = azurerm_network_security_rule.nsr-hub-ingress-spoke.id
}

resource "azurerm_network_interface_security_group_association" "ni-spoke-1-vm-2-nsg" {
  network_interface_id      = azurerm_network_interface.ni-spoke-1-vm-2.id
  network_security_group_id = azurerm_network_security_rule.nsr-hub-ingress-spoke.id
}

resource "azurerm_network_interface_security_group_association" "ni-spoke-2-vm-1-nsg" {
  network_interface_id      = azurerm_network_interface.ni-spoke-2-vm-1.id
  network_security_group_id = azurerm_network_security_rule.nsr-hub-ingress-spoke.id
}

resource "azurerm_network_interface_security_group_association" "ni-spoke-2-vm-2-nsg" {
  network_interface_id      = azurerm_network_interface.ni-spoke-2-vm-2.id
  network_security_group_id = azurerm_network_security_rule.nsr-hub-ingress-spoke.id
}