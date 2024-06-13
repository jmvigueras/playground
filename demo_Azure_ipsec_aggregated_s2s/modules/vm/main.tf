#-----------------------------------------------------------------------------------
# VMs
#-----------------------------------------------------------------------------------
// Create public IP address for NI subnet_1
resource "azurerm_public_ip" "vm_ni_pip" {
  name                = "${var.prefix}-vm-ni-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Network Interface VM Test Spoke-1 subnet 1
resource "azurerm_network_interface" "vm_ni" {
  name                = "${var.prefix}-vm-ni"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ni_ip == null ? cidrhost(var.subnet_cidr, 10) : var.ni_ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm_ni_pip.id
  }

  tags = var.tags
}
// Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.vm_ni.id]

  custom_data = var.user_data != "" ? base64encode(var.user_data) : base64encode(file("${path.module}/templates/user-data.tpl"))

  os_disk {
    name                 = "${var.prefix}-disk${random_string.random.result}-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  computer_name                   = "${var.prefix}-vm"
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(var.rsa-public-key)
  }
  boot_diagnostics {
    storage_account_uri = var.storage-account_endpoint
  }
}


# Random string to add at disk name
resource "random_string" "random" {
  length  = 3
  special = false
  numeric = false
  upper   = false
}