//  Network Security Group

resource "azurerm_network_security_group" "nsg-spoke-vm" {
  name                = "${var.prefix}-nsg-spoke-vm"
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_security_rule" "nsr-ingress-spoke-vm" {
  name                        = "${var.prefix}-nsr-ingress-all"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resourcegroup_name
  network_security_group_name = azurerm_network_security_group.nsg-spoke-vm.name
}

resource "azurerm_network_security_rule" "nsr-egress-spoke-vm" {
  name                        = "${var.prefix}-nsr-egress-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resourcegroup_name
  network_security_group_name = azurerm_network_security_group.nsg-spoke-vm.name
}