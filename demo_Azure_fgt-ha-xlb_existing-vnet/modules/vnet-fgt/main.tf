#----------------------------------------------------------------------------------
# Create VNET FGT and subnets
#----------------------------------------------------------------------------------
# Create subnets
resource "azurerm_subnet" "subnet-hamgmt" {
  name                 = "${var.prefix}-subnet-hamgmt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.subnet_mgmt_cidr]
}
resource "azurerm_subnet" "subnet-public" {
  name                 = "${var.prefix}-subnet-public"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.subnet_public_cidr]
}
resource "azurerm_subnet" "subnet-private" {
  name                 = "${var.prefix}-subnet-private"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.subnet_private_cidr]
}

#----------------------------------------------------------------------------------
# Create public IPs and interfaces (Active and passive FGT)
#----------------------------------------------------------------------------------
// Active MGMT public IP
resource "azurerm_public_ip" "fgt-1-mgmt-ip" {
  name                = "${var.prefix}-fgt-1-mgmt-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Passive MGMT public IP
resource "azurerm_public_ip" "fgt-2-mgmt-ip" {
  name                = "${var.prefix}-fgt-2-mgmt-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Active FGT Network Interface MGMT
resource "azurerm_network_interface" "ni-fgt-1-mgmt" {
  name                          = local.fgt-1_ni_mgmt_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-hamgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_mgmt_ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.fgt-1-mgmt-ip.id
  }

  tags = var.tags
}
// Passive FGT Network Interface MGMT
resource "azurerm_network_interface" "ni-fgt-2-mgmt" {
  name                          = local.fgt-2_ni_mgmt_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-hamgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-2_ni_mgmt_ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.fgt-2-mgmt-ip.id
  }

  tags = var.tags
}
#----------------------------------------------------------------------------------
# Create public IPs and interfaces (Active and passive FGT)
#----------------------------------------------------------------------------------
// Active FGT Network Interface Public (with external LB)
resource "azurerm_network_interface" "ni-fgt-1-public" {
  name                          = local.fgt-1_ni_public_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_public_ip
  }

  tags = var.tags
}
// Passive FGT Network Interface Public (with public IP SDN connector)
resource "azurerm_network_interface" "ni-fgt-2-public" {
  name                          = local.fgt-2_ni_public_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-2_ni_public_ip
  }

  tags = var.tags
}
#----------------------------------------------------------------------------------
# Create private IPs and interfaces (Active and passive FGT)
#----------------------------------------------------------------------------------
// Active FGT Network Interface Private
resource "azurerm_network_interface" "ni-fgt-1-private" {
  name                          = local.fgt-1_ni_private_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-private.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_private_ip
  }

  tags = var.tags
}
// Passive FGT Network Interface Private
resource "azurerm_network_interface" "ni-fgt-2-private" {
  name                          = local.fgt-2_ni_private_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-private.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-2_ni_private_ip
  }

  tags = var.tags
}