#----------------------------------------------------------------------------------
# Create VNET FGT and subnets
#----------------------------------------------------------------------------------
# Create VNet
resource "azurerm_virtual_network" "vnet-fgt" {
  name                = "${var.prefix}-vnet-fgt"
  address_space       = [var.vnet-fgt_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
# Create subnets
resource "azurerm_subnet" "subnet-hamgmt" {
  name                 = "${var.prefix}-subnet-hamgmt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [local.subnet_mgmt_cidr]
}
resource "azurerm_subnet" "subnet-public" {
  name                 = "${var.prefix}-subnet-public"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [local.subnet_public_cidr]
}
resource "azurerm_subnet" "subnet-private" {
  name                 = "${var.prefix}-subnet-private"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [local.subnet_private_cidr]
}
resource "azurerm_subnet" "subnet-public-1" {
  name                 = "${var.prefix}-subnet-public-1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [local.subnet_public_1_cidr]
}
/*
resource "azurerm_subnet" "subnet-bastion" {
  name                 = "${var.prefix}-subnet-bastion"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [local.subnet_bastion_cidr]
}
resource "azurerm_subnet" "subnet-vgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [local.subnet_vgw_cidr]
}
resource "azurerm_subnet" "subnet-routeserver" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [local.subnet_routeserver_cidr]
}
*/

#----------------------------------------------------------------------------------
# Create public IPs and interfaces (Active and passive FGT)
#----------------------------------------------------------------------------------
// Active service public IP
resource "azurerm_public_ip" "active-public-ip" {
  count               = var.config_xlb ? 0 : 1
  name                = local.fgt_1_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Passive service public IP
resource "azurerm_public_ip" "passive-public-ip" {
  count               = var.config_xlb ? 0 : 1
  name                = local.fgt_2_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Active MGMT public IP
resource "azurerm_public_ip" "active-mgmt-ip" {
  name                = "${var.prefix}-active-mgmt-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Passive MGMT public IP
resource "azurerm_public_ip" "passive-mgmt-ip" {
  name                = "${var.prefix}-passive-mgmt-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}

// Active FGT Network Interface MGMT
resource "azurerm_network_interface" "ni-active-mgmt" {
  name                          = local.fgt_1_ni_mgmt_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-hamgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_1_ni_mgmt_ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.active-mgmt-ip.id
  }

  tags = var.tags
}
// Active FGT Network Interface Public (with public IP SDN connector)
resource "azurerm_network_interface" "ni-active-public_sdn" {
  count                         = var.config_xlb ? 0 : 1
  name                          = local.fgt_1_ni_public_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_1_ni_public_ip
    public_ip_address_id          = azurerm_public_ip.active-public-ip[0].id
  }

  tags = var.tags
}
// Active FGT Network Interface Public (without public IP External LB)
resource "azurerm_network_interface" "ni-active-public_xlb" {
  count                         = var.config_xlb ? 1 : 0
  name                          = local.fgt_1_ni_public_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_1_ni_public_ip
  }

  tags = var.tags
}
// Active FGT Network Interface Private
resource "azurerm_network_interface" "ni-active-private" {
  name                          = local.fgt_1_ni_private_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-private.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_1_ni_private_ip
  }

  tags = var.tags
}
// Active FGT Network Interface Public 1
resource "azurerm_network_interface" "ni-active-public-1" {
  name                          = local.fgt_1_ni_public_1_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public-1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_1_ni_public_1_ip
  }

  tags = var.tags
}
// Passive FGT Network Interface MGMT
resource "azurerm_network_interface" "ni-passive-mgmt" {
  name                          = local.fgt_2_ni_mgmt_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-hamgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_2_ni_mgmt_ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.passive-mgmt-ip.id
  }

  tags = var.tags
}
// Passive FGT Network Interface Public (with public IP SDN connector)
resource "azurerm_network_interface" "ni-passive-public_fgsp" {
  count                         = var.config_xlb ? 0 : 1
  name                          = local.fgt_2_ni_public_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_2_ni_public_ip
    public_ip_address_id          = azurerm_public_ip.passive-public-ip[0].id
  }

  tags = var.tags
}
// Passive FGT Network Interface Public (without public IP External LB)
resource "azurerm_network_interface" "ni-passive-public_xlb" {
  count                         = var.config_xlb ? 1 : 0
  name                          = local.fgt_2_ni_public_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_2_ni_public_ip
  }

  tags = var.tags
}
// Passive FGT Network Interface Private
resource "azurerm_network_interface" "ni-passive-private" {
  name                          = local.fgt_2_ni_private_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-private.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_2_ni_private_ip
  }

  tags = var.tags
}
// Passive FGT Network Interface Public 1
resource "azurerm_network_interface" "ni-passive-public-1" {
  name                          = local.fgt_2_ni_public_1_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public-1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_2_ni_public_1_ip
  }

  tags = var.tags
}