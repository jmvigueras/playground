##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################
resource "azurerm_virtual_machine" "fgt-1" {
  name                         = "${var.prefix}-fgt-1"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [var.fgt-active-ni_ids[var.fgt_ni_0], var.fgt-active-ni_ids[var.fgt_ni_1], var.fgt-active-ni_ids[var.fgt_ni_2]]
  primary_network_interface_id = var.fgt-active-ni_ids[var.fgt_ni_0]
  vm_size                      = var.size

  lifecycle {
    ignore_changes = [os_profile]
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.fgt_offer
    sku       = var.fgt_sku[var.license_type]
    version   = var.fgt_version
  }

  plan {
    publisher = var.publisher
    product   = var.fgt_offer
    name      = var.fgt_sku[var.license_type]
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk-fgt-1-${random_string.random.result}"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-datadisk-fgt-1-${random_string.random.result}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "fgt-1"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.fgt_config_1
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage-account_endpoint
  }

  tags = var.tags
}

##############################################################################################################
# FGT PASSIVE VM
##############################################################################################################
resource "azurerm_virtual_machine" "fgt-2" {
  count                        = var.fgt_passive ? 1 : 0
  name                         = "${var.prefix}-fgt-2"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [var.fgt-passive-ni_ids[var.fgt_ni_0], var.fgt-passive-ni_ids[var.fgt_ni_1], var.fgt-passive-ni_ids[var.fgt_ni_2]]
  primary_network_interface_id = var.fgt-passive-ni_ids[var.fgt_ni_0]
  vm_size                      = var.size

  lifecycle {
    ignore_changes = [os_profile]
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.fgt_offer
    sku       = var.fgt_sku[var.license_type]
    version   = var.fgt_version
  }

  plan {
    publisher = var.publisher
    product   = var.fgt_offer
    name      = var.fgt_sku[var.license_type]
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk-fgt-2-${random_string.random.result}"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-datadisk-fgt-2-${random_string.random.result}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "fgt-2"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.fgt_config_2
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage-account_endpoint
  }

  tags = var.tags
}

# Random string to add at disk name
resource "random_string" "random" {
  length  = 5
  special = false
  numeric = false
  upper   = false
}