// VM Region A VNET spoke 1
resource "azurerm_network_interface" "ni-vm-spoke-1" {
  name                = "${var.prefix}-ni-vm-spoke-1"
  location            = var.regiona
  resource_group_name = azurerm_resource_group.rg-regiona.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet-spoke.subnet-spoke_ids["spoke-1-vm"]
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_linux_virtual_machine" "vm-spoke-1" {
  name                            = "${var.prefix}-vm-spoke-1"
  resource_group_name             = azurerm_resource_group.rg-regiona.name
  location                        = var.regiona
  size                            = var.size-vm
  admin_username                  = var.adminusername
  admin_password                  = var.adminpassword
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.ni-vm-spoke-1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

// VM Region A VNET spoke 2
resource "azurerm_network_interface" "ni-vm-spoke-2" {
  name                = "${var.prefix}-ni-vm-spoke-2"
  location            = var.regiona
  resource_group_name = azurerm_resource_group.rg-regiona.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet-spoke.subnet-spoke_ids["spoke-2-vm"]
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_linux_virtual_machine" "vm-spoke-2" {
  name                            = "${var.prefix}-vm-spoke-2"
  resource_group_name             = azurerm_resource_group.rg-regiona.name
  location                        = var.regiona
  size                            = var.size-vm
  admin_username                  = var.adminusername
  admin_password                  = var.adminpassword
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.ni-vm-spoke-2.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}