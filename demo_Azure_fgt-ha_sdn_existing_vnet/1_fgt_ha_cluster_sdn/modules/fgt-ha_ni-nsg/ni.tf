#----------------------------------------------------------------------------------
# Create public IPs and interfaces (Active and passive FGT)
#----------------------------------------------------------------------------------
// Active service public IP
resource "azurerm_public_ip" "active-public-ip-1" {
  name                = "${var.prefix}-active-public-ip-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
resource "azurerm_public_ip" "active-public-ip-2" {
  name                = "${var.prefix}-active-public-ip-2"
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
  name                          = "${var.prefix}-ni-active-mgmt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["mgmt"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_mgmt_ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.active-mgmt-ip.id
  }

  tags = var.tags
}
// Active FGT Network Interface Public
resource "azurerm_network_interface" "ni-active-public" {
  name                          = "${var.prefix}-ni-active-public"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["public"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_public_ip_1
    public_ip_address_id          = azurerm_public_ip.active-public-ip-1.id
    primary                       = true
  }
  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = var.subnet_ids["public"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_public_ip_2
    public_ip_address_id          = azurerm_public_ip.active-public-ip-2.id
  }

  tags = var.tags
}
// Active FGT Network Interface Private
resource "azurerm_network_interface" "ni-active-private" {
  name                          = "${var.prefix}-ni-active-private"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["private"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-1_ni_private_ip
  }

  tags = var.tags
}

// Passive FGT Network Interface MGMT
resource "azurerm_network_interface" "ni-passive-mgmt" {
  name                          = "${var.prefix}-ni-passive-mgmt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["mgmt"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-2_ni_mgmt_ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.passive-mgmt-ip.id
  }

  tags = var.tags
}
// Passive FGT Network Interface Public
resource "azurerm_network_interface" "ni-passive-public" {
  name                          = "${var.prefix}-ni-passive-public"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["public"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-2_ni_public_ip_1
    primary                       = true
  }
  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = var.subnet_ids["public"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-2_ni_public_ip_2
  }

  tags = var.tags
}
// Passive FGT Network Interface Private
resource "azurerm_network_interface" "ni-passive-private" {
  name                          = "${var.prefix}-ni-passive-private"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["private"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt-2_ni_private_ip
  }

  tags = var.tags
}