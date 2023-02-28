##################################################################
# VMs spoke 1
##################################################################

resource "azurerm_virtual_machine" "vm-spoke-1-subnet1" {
  name                            = "${var.prefix}-vm-spoke-1-subnet1"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  vm_size                         = var.size-vm
  network_interface_ids           = [module.vnet-spoke.ni_ids["spoke-1_subnet1"]]

  storage_os_disk {
    name                 = "${var.prefix}-disk-vm-spoke-1-s1"
    caching              = "ReadWrite"
    managed_disk_type    = "Standard_LRS"
    create_option        = "FromImage"
  } 

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm-spoke-1-s1"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.lnx_custom_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine" "vm-spoke-1-subnet2" {
  name                            = "${var.prefix}-vm-spoke-1-subnet2"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  vm_size                         = var.size-vm
  network_interface_ids           = [module.vnet-spoke.ni_ids["spoke-1_subnet2"]]

  storage_os_disk {
    name                 = "${var.prefix}-disk-vm-spoke-1-s2"
    caching              = "ReadWrite"
    managed_disk_type    = "Standard_LRS"
    create_option        = "FromImage"
  } 

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm-spoke-1-s2"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.lnx_custom_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
  }
}

##################################################################
# VMs spoke 2
##################################################################

resource "azurerm_virtual_machine" "vm-spoke-2-subnet1" {
  name                            = "${var.prefix}-vm-spoke-2-subnet1"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  vm_size                         = var.size-vm
  network_interface_ids           = [module.vnet-spoke.ni_ids["spoke-2_subnet1"]]

  storage_os_disk {
    name                 = "${var.prefix}-disk-vm-spoke-2-s1"
    caching              = "ReadWrite"
    managed_disk_type    = "Standard_LRS"
    create_option        = "FromImage"
  } 

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm-spoke-2-s1"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.lnx_custom_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine" "vm-spoke-2-subnet2" {
  name                            = "${var.prefix}-vm-spoke-2-subnet2"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  vm_size                         = var.size-vm
  network_interface_ids           = [module.vnet-spoke.ni_ids["spoke-2_subnet2"]]

  storage_os_disk {
    name                 = "${var.prefix}-disk-vm-spoke-2-s2"
    caching              = "ReadWrite"
    managed_disk_type    = "Standard_LRS"
    create_option        = "FromImage"
  } 

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm-spoke-2-s2"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.lnx_custom_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
  }
}

data "template_file" "lnx_custom_data" {
  template = file("./templates/customdata-lnx.tpl")

  vars = {
  }
}



