######################################################################
## Create VNET SPOKE 1
######################################################################
// VNET 
resource "azurerm_virtual_network" "vnet-spoke-1" {
  name                = "${var.prefix}-vnet-spoke-1"
  address_space       = [var.vnet-spoke-1_net]
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

// Subnets
resource "azurerm_subnet" "subnet-spoke-1-vm" {
  name                 = "${var.prefix}-subnet-spoke-1-vm"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_net,1,0)]
}

resource "azurerm_subnet" "subnet-spoke-1-route-server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_net,3,4)]
}

resource "azurerm_subnet" "subnet-spoke-1-vgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_net,3,5)]
}

// Network Interface VM Test Spoke-1 VNET
resource "azurerm_network_interface" "ni-spoke-1-vm" {
  name                          = "${var.prefix}-ni-spoke-1-vm"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-spoke-1-vm.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-spoke-1-vm.address_prefixes[0],10)
    primary                       = true
  }

  tags = {
    environment = var.tag_env
  }
}


######################################################################
## Create VNET SPOKE 2
######################################################################
// VNET
resource "azurerm_virtual_network" "vnet-spoke-2" {
  name                = "${var.prefix}-vnet-spoke-2"
  address_space       = [var.vnet-spoke-2_net]
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

// Subnets
resource "azurerm_subnet" "subnet-spoke-2-vm" {
  name                 = "${var.prefix}-subnet-spoke-2-vm"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_net,1,0)]
}

resource "azurerm_subnet" "subnet-spoke-2-route-server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_net,3,4)]
}

resource "azurerm_subnet" "subnet-spoke-2-vgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_net,3,5)]
}

// Network Interface VM Test Spoke-2 VNET
resource "azurerm_network_interface" "ni-spoke-2-vm" {
  name                          = "${var.prefix}-ni-spoke-2-vm"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-spoke-2-vm.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-spoke-2-vm.address_prefixes[0],10)
    primary                       = true
  }

  tags = {
    environment = var.tag_env
  }
}