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
resource "azurerm_subnet" "subnet-protected" {
  name                 = "${var.prefix}-subnet-protected"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-fgt.name
  address_prefixes     = [local.subnet_protected_cidr]
}