######################################################################
## Create VNET FGT and subnets
######################################################################
resource "azurerm_virtual_network" "vnet-fgt" {
  name                = "${var.prefix}-vnet-fgt"
  address_space       = [var.vnet-fgt_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet" "subnet-ha" {
  name                 = "${var.prefix}-subnet-ha"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [cidrsubnet(var.vnet-fgt_cidr, 3, 0)]
}

resource "azurerm_subnet" "subnet-mgmt" {
  name                 = "${var.prefix}-subnet-mgmt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [cidrsubnet(var.vnet-fgt_cidr, 3, 1)]
}

resource "azurerm_subnet" "subnet-public" {
  name                 = "${var.prefix}-subnet-public"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [cidrsubnet(var.vnet-fgt_cidr, 3, 2)]
}

resource "azurerm_subnet" "subnet-private" {
  name                 = "${var.prefix}-subnet-private"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [cidrsubnet(var.vnet-fgt_cidr, 3, 3)]
}

