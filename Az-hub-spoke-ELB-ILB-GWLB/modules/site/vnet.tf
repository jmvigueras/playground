// Create Virtual Network spoke FGT
resource "azurerm_virtual_network" "vnet-site-fgt" {
  name                = "${var.prefix}-${var.site["site_id"]}-vnet-site-fgt"
  address_space       = [cidrsubnet(var.site["cidr"],1,0)]
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_subnet" "subnet-hamgmt" {
  name                 = "${var.prefix}-${var.site["site_id"]}-subnet-hamgmt-site"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-site-fgt.name
  address_prefixes     = [cidrsubnet(var.site["cidr"],4,1)]
}

resource "azurerm_subnet" "subnet-public" {
  name                 = "${var.prefix}-${var.site["site_id"]}-subnet-public-site"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-site-fgt.name
  address_prefixes     = [cidrsubnet(var.site["cidr"],4,2)]
}

resource "azurerm_subnet" "subnet-private" {
  name                 = "${var.prefix}-${var.site["site_id"]}-subnet-private-site"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-site-fgt.name
  address_prefixes     = [cidrsubnet(var.site["cidr"],4,3)]
}

// Allocated Public IPs FGT MGMT and Public
resource "azurerm_public_ip" "site-fgt-mgmt-ip" {
  name                = "${var.prefix}-${var.site["site_id"]}-site-fgt-mgmt-ip"
  location            = var.location
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_public_ip" "site-fgt-public-ip" {
  name                = "${var.prefix}-${var.site["site_id"]}-site-fgt-public-ip"
  location            = var.location
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"

  tags = {
    environment = var.tag_env
  }
}

// Active FGT Network Interface port1
resource "azurerm_network_interface" "ni-site-port1" {
  name                          = "${var.prefix}-${var.site["site_id"]}-ni-site-fgt-port1"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-hamgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-hamgmt.address_prefixes[0],10)
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.site-fgt-mgmt-ip.id
  }

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_interface" "ni-site-port2" {
  name                          = "${var.prefix}-${var.site["site_id"]}-ni-site-fgt-port2"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-public.address_prefixes[0],10)
    public_ip_address_id          = azurerm_public_ip.site-fgt-public-ip.id
  }

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_interface" "ni-site-port3" {
  name                          = "${var.prefix}-${var.site["site_id"]}-ni-site-fgt-port3"
  location                      = var.location
  resource_group_name           = var.resourcegroup_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-private.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnet-private.address_prefixes[0],10)
  }

  tags = {
    environment = var.tag_env
  }
}

// Create Virtual Network Site Spoke
resource "azurerm_virtual_network" "vnet-site-fgt-spoke" {
  name                = "${var.prefix}-${var.site["site_id"]}-vnet-site-fgt-spoke"
  address_space       = [cidrsubnet(var.site["cidr"],1,1)]
  location            = var.location
  resource_group_name = var.resourcegroup_name

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_subnet" "subnet-site-spoke" {
  name                 = "${var.prefix}-${var.site["site_id"]}-subnet-site-spoke"
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet-site-fgt-spoke.name
  address_prefixes     = [cidrsubnet(var.site["cidr"],4,8)]
}

// Create Peerings spoke vnet to FGT vnet

resource "azurerm_virtual_network_peering" "peer-site-spoke-toFGT-1" {
  name                      = "${var.prefix}-site-peer-site-spoke-toFGT-1"
  resource_group_name       = var.resourcegroup_name
  virtual_network_name      = azurerm_virtual_network.vnet-site-fgt.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-site-fgt-spoke.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer-site-spoke-toFGT-2" {
  name                      = "${var.prefix}-site-peer-site-spoke-toFGT-2"
  resource_group_name       = var.resourcegroup_name
  virtual_network_name      = azurerm_virtual_network.vnet-site-fgt-spoke.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-site-fgt.id
  allow_forwarded_traffic   = true
}

