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
  name                           = local.fgt-1_ni_mgmt_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  accelerated_networking_enabled = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["mgmt"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_mgmt_ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.fgt-1-mgmt-ip.id
  }

  tags = var.tags
}
// Passive FGT Network Interface MGMT
resource "azurerm_network_interface" "ni-fgt-2-mgmt" {
  name                           = local.fgt-2_ni_mgmt_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  accelerated_networking_enabled = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["mgmt"]
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
  name                           = local.fgt-1_ni_public_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["public"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_public_ip
  }

  tags = var.tags
}
// Passive FGT Network Interface Public (with public IP SDN connector)
resource "azurerm_network_interface" "ni-fgt-2-public" {
  name                           = local.fgt-2_ni_public_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["public"]
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
  name                           = local.fgt-1_ni_private_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["private"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_private_ip
  }

  tags = var.tags
}
// Passive FGT Network Interface Private
resource "azurerm_network_interface" "ni-fgt-2-private" {
  name                           = local.fgt-2_ni_private_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["private"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-2_ni_private_ip
  }

  tags = var.tags
}