#-------------------------------------------------------------------------------------
# FGT NSG
#-------------------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg-mgmt-ha" {
  name                = "${var.prefix}-nsg-mgmt-ha"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
# FGT NSG HA MGMT
resource "azurerm_network_security_rule" "nsr-ingress-mgmt-ha-sync" {
  name                        = "${var.prefix}-nsr-ingress-sync"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.subnet_cidrs["mgmt"]
  destination_address_prefix  = var.subnet_cidrs["mgmt"]
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-mgmt-ha.name
}
resource "azurerm_network_security_rule" "nsr-ingress-mgmt-ha-ssh" {
  name                        = "${var.prefix}-nsr-ingress-ssh"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.admin_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-mgmt-ha.name
}
resource "azurerm_network_security_rule" "nsr-ingress-mgmt-ha-https" {
  name                        = "${var.prefix}-nsr-ingress-https"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.admin_port
  source_address_prefix       = var.admin_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-mgmt-ha.name
}
resource "azurerm_network_security_rule" "nsr-egress-mgmt-ha-all" {
  name                        = "${var.prefix}-nsr-egress-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-mgmt-ha.name
}
# FGT NSG PUBLIC (FGT)
resource "azurerm_network_security_group" "nsg-public" {
  name                = "${var.prefix}-nsg-public"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
resource "azurerm_network_security_rule" "nsr-ingress-public-ipsec-500" {
  name                        = "${var.prefix}-nsr-ingress-ipsec-500"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "500"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-public.name
}
resource "azurerm_network_security_rule" "nsr-ingress-public-ipsec-4500" {
  name                        = "${var.prefix}-nsr-ingress-ipsec-4500"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "4500"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-public.name
}
resource "azurerm_network_security_rule" "nsr-ingress-public-icmp" {
  name                        = "${var.prefix}-nsr-ingress-icmp"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-public.name
}
resource "azurerm_network_security_rule" "nsr-egress-public-all" {
  name                        = "${var.prefix}-nsr-egress-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-public.name
}
# FGT NSG PUBLIC (subnet default)
resource "azurerm_network_security_group" "nsg-public-default" {
  name                = "${var.prefix}-nsg-subnet-public"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
resource "azurerm_network_security_rule" "nsr-ingress-public-default-allow-all" {
  name                        = "${var.prefix}-nsr-ingress-subnet-public-allow-all"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-public-default.name
}
resource "azurerm_network_security_rule" "nsr-egress-public-default-allow-all" {
  name                        = "${var.prefix}-nsr-egress-subnet-public-allow-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-public-default.name
}
# FGT NSG PRIVATE
resource "azurerm_network_security_group" "nsg-private" {
  name                = "${var.prefix}-nsg-private"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
resource "azurerm_network_security_rule" "nsr-ingress-private-all" {
  name                        = "${var.prefix}-nsr-ingress-all"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-private.name
}
resource "azurerm_network_security_rule" "nsr-egress-private-all" {
  name                        = "${var.prefix}-nsr-egress-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-private.name
}
#-------------------------------------------------------------------------------------
# Associate NSG to interfaces (Public interfaces FGT)
# - Connect the security group to the network interfaces FGT active
resource "azurerm_network_interface_security_group_association" "ni-fgt-1-mgmt-nsg" {
  network_interface_id      = azurerm_network_interface.ni-fgt-1-mgmt.id
  network_security_group_id = azurerm_network_security_group.nsg-mgmt-ha.id
}
resource "azurerm_network_interface_security_group_association" "ni-fgt-1-public-nsg" {
  network_interface_id      = azurerm_network_interface.ni-fgt-1-public.id
  network_security_group_id = azurerm_network_security_group.nsg-public-default.id
}
# - Connect the security group to the network interfaces FGT passive
resource "azurerm_network_interface_security_group_association" "ni-fgt-2-mgmt-nsg" {
  network_interface_id      = azurerm_network_interface.ni-fgt-2-mgmt.id
  network_security_group_id = azurerm_network_security_group.nsg-mgmt-ha.id
}
resource "azurerm_network_interface_security_group_association" "ni-fgt-2-public-nsg" {
  network_interface_id      = azurerm_network_interface.ni-fgt-2-public.id
  network_security_group_id = azurerm_network_security_group.nsg-public-default.id
}
#-------------------------------------------------------------------------------------
# Associate NSG to subnet
resource "azurerm_subnet_network_security_group_association" "subnet-private-nsg" {
  subnet_id                 = var.subnet_ids["private"]
  network_security_group_id = azurerm_network_security_group.nsg-private.id
}
resource "azurerm_subnet_network_security_group_association" "subnet-public-nsg" {
  subnet_id                 = var.subnet_ids["public"]
  network_security_group_id = azurerm_network_security_group.nsg-public-default.id
}