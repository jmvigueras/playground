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
  source_address_prefix       = azurerm_subnet.subnet-hamgmt.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.subnet-hamgmt.address_prefixes[0]
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-mgmt-ha.name
}
resource "azurerm_network_security_rule" "nsr-ingress-mgmt-ha-fmg" {
  name                        = "${var.prefix}-nsr-ingress-fmg"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "541"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-mgmt-ha.name
}
resource "azurerm_network_security_rule" "nsr-ingress-mgmt-ha-ssh" {
  count                       = length(var.admin_cidrs)
  name                        = "${var.prefix}-nsr-ingress-ssh"
  priority                    = 1010 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.admin_cidrs[count.index]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-mgmt-ha.name
}
resource "azurerm_network_security_rule" "nsr-ingress-mgmt-ha-https" {
  count                       = length(var.admin_cidrs)
  name                        = "${var.prefix}-nsr-ingress-https"
  priority                    = 1010 + length(var.admin_cidrs) + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.admin_port
  source_address_prefix       = var.admin_cidrs[count.index]
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
resource "azurerm_network_security_rule" "nsr-ingress-public-allow-all" {
  name                        = "${var.prefix}-nsr-ingress-allow-all"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-public.name
}
/*
resource "azurerm_network_security_rule" "nsr-ingress-public-vxlan-4789" {
  name                        = "${var.prefix}-nsr-ingress-vxlan-4789"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-public.name
}
resource "azurerm_network_security_rule" "nsr-ingress-public-ipsec-500" {
  name                        = "${var.prefix}-nsr-ingress-ipsec-500"
  priority                    = 1002
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
  priority                    = 1003
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
*/
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
resource "azurerm_network_interface_security_group_association" "ni-active-mgmt-nsg" {
  network_interface_id      = azurerm_network_interface.ni-active-mgmt.id
  network_security_group_id = azurerm_network_security_group.nsg-mgmt-ha.id
}
resource "azurerm_network_interface_security_group_association" "ni-active-public-nsg" {
  network_interface_id      = local.fgt_1_ni_public_id
  network_security_group_id = azurerm_network_security_group.nsg-public.id
}
resource "azurerm_network_interface_security_group_association" "ni-active-public-1-nsg" {
  network_interface_id      = azurerm_network_interface.ni-active-public-1.id
  network_security_group_id = azurerm_network_security_group.nsg-public.id
}
# - Connect the security group to the network interfaces FGT passive
resource "azurerm_network_interface_security_group_association" "ni-passive-mgmt-nsg" {
  network_interface_id      = azurerm_network_interface.ni-passive-mgmt.id
  network_security_group_id = azurerm_network_security_group.nsg-mgmt-ha.id
}
resource "azurerm_network_interface_security_group_association" "ni-passive-public-nsg" {
  network_interface_id      = local.fgt_2_ni_public_id
  network_security_group_id = azurerm_network_security_group.nsg-public.id
}
resource "azurerm_network_interface_security_group_association" "ni-passive-public-1-nsg" {
  network_interface_id      = azurerm_network_interface.ni-passive-public-1.id
  network_security_group_id = azurerm_network_security_group.nsg-public.id
}
#-------------------------------------------------------------------------------------
# Associate NSG to subnet
resource "azurerm_subnet_network_security_group_association" "subnet-private-nsg" {
  subnet_id                 = azurerm_subnet.subnet-private.id
  network_security_group_id = azurerm_network_security_group.nsg-private.id
}
resource "azurerm_subnet_network_security_group_association" "subnet-public-nsg" {
  subnet_id                 = azurerm_subnet.subnet-public.id
  network_security_group_id = azurerm_network_security_group.nsg-public-default.id
}
/*
#-----------------------------------------------------------------------------------
# Bastion NSG
# - Bastion: allow only traffic from admin_cidr (associated to bastion ni)
# - Bastion: allow all traffic (default to Subenet)
#-----------------------------------------------------------------------------------
# NSG allow acces admin_cidr
resource "azurerm_network_security_group" "nsg_bastion_admin_cidr" {
  name                = "${var.prefix}-nsg-bastion-admin-cidr"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
resource "azurerm_network_security_rule" "nsr_bastion_admin_cidr_ingress_allow_all" {
  name                        = "${var.prefix}-nsr-ingress-admin-cidr-allow-all"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.admin_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion_admin_cidr.name
}
resource "azurerm_network_security_rule" "nsr_bastion_admin_cidr_egress_allow_all" {
  name                        = "${var.prefix}-nsr-egress-admin-cidr-allow-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion_admin_cidr.name
}

# NSG allow all access 
resource "azurerm_network_security_group" "nsg_bastion_default" {
  name                = "${var.prefix}-nsg-bastion-default"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
resource "azurerm_network_security_rule" "nsr_bastion_default_ingress_allow_all" {
  name                        = "${var.prefix}-nsr-ingress-default-allow-all"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion_default.name
}
resource "azurerm_network_security_rule" "nsr_bastion_default_egress_allow_all" {
  name                        = "${var.prefix}-nsr-egress-default-allow-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion_default.name
}
# Connect the security group to Bastion Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_bastion_nsg" {
  subnet_id                 = azurerm_subnet.subnet-bastion.id
  network_security_group_id = azurerm_network_security_group.nsg_bastion_default.id
}
*/