######################################################################
## Create VNET SPOKE 1
######################################################################
// VNET 
resource "azurerm_virtual_network" "vnet-spoke-1" {
  name                = "${var.prefix}-vnet-spoke-1"
  address_space       = [var.vnet-spoke-1_cidr]
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

// Subnets
resource "azurerm_subnet" "subnet-spoke-1-subnet1" {
  name                 = "${var.prefix}-spoke-1-subnet1"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_cidr,2,0)]
}

resource "azurerm_subnet" "subnet-spoke-1-subnet2" {
  name                 = "${var.prefix}-spoke-1-subnet2"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_cidr,2,2)]
}

resource "azurerm_subnet" "subnet-spoke-1-routeserver" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_cidr,4,12)]
}

resource "azurerm_subnet" "subnet-spoke-1-vgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_cidr,4,13)]
}

resource "azurerm_subnet" "subnet-spoke-1-pl" {
  name                 = "PrivateLinkSubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_cidr,4,14)]

  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "subnet-spoke-1-pl-s" {
  name                 = "PrivateLinkServicesSubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-1.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-1_cidr,4,15)]

  private_link_service_network_policies_enabled = true
}

// Network Interface VM Test Spoke-1 subnet 1
resource "azurerm_network_interface" "ni-spoke-1-vm-1" {
  name                          = "${var.prefix}-ni-spoke-1-vm-1"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-spoke-1-subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-spoke-1-subnet1.address_prefixes[0],10)
    primary                       = true
  }

  tags = {
    environment = var.tag_env
  }
}

// Network Interface VM Test Spoke-1 subnet 2
resource "azurerm_network_interface" "ni-spoke-1-vm-2" {
  name                          = "${var.prefix}-ni-spoke-1-vm-2"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-spoke-1-subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-spoke-1-subnet2.address_prefixes[0],10)
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
  address_space       = [var.vnet-spoke-2_cidr]
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

// Subnets
resource "azurerm_subnet" "subnet-spoke-2-subnet1" {
  name                 = "${var.prefix}-spoke-2-subnet1"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_cidr,2,0)]
}

resource "azurerm_subnet" "subnet-spoke-2-subnet2" {
  name                 = "${var.prefix}-spoke-2-subnet2"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_cidr,2,2)]
}

resource "azurerm_subnet" "subnet-spoke-2-routeserver" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_cidr,4,12)]
}

resource "azurerm_subnet" "subnet-spoke-2-vgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_cidr,4,13)]
}

resource "azurerm_subnet" "subnet-spoke-2-pl" {
  name                 = "PrivateLinkSubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_cidr,4,14)]

  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "subnet-spoke-2-pl-s" {
  name                 = "PrivateLinkServicesSubnet"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke-2.name
  address_prefixes     = [cidrsubnet(var.vnet-spoke-2_cidr,4,15)]

  private_link_service_network_policies_enabled = true
}

// Network Interface VM Test spoke-2 subnet 1
resource "azurerm_network_interface" "ni-spoke-2-vm-1" {
  name                          = "${var.prefix}-ni-spoke-2-vm-1"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-spoke-2-subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-spoke-2-subnet1.address_prefixes[0],10)
    primary                       = true
  }

  tags = {
    environment = var.tag_env
  }
}

// Network Interface VM Test spoke-2 subnet 2
resource "azurerm_network_interface" "ni-spoke-2-vm-2" {
  name                          = "${var.prefix}-ni-spoke-2-vm-2"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-spoke-2-subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-spoke-2-subnet2.address_prefixes[0],10)
    primary                       = true
  }

  tags = {
    environment = var.tag_env
  }
}