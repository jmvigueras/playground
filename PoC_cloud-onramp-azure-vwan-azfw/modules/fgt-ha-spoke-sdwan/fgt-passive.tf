#------------------------------------------------------------------------------------------------------------
# FGT PASSIVE VM
#------------------------------------------------------------------------------------------------------------
# Create virtual machine FGT passive
resource "azurerm_virtual_machine" "fgt-passive" {
  count                        = var.fgt-passive-ni_ids != null && var.site["ha"] ? 1 : 0
  name                         = "${var.prefix}-${var.site["id"]}-fgt-passive"
  location                     = var.location
  resource_group_name          = var.resourcegroup_name
  network_interface_ids        = var.fgt-passive-ni_ids
  primary_network_interface_id = var.fgt-passive-ni_ids[0]
  vm_size                      = var.size

  lifecycle {
    ignore_changes = [os_profile]
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.fgtoffer
    sku       = var.license_type == "byol" ? var.fgtsku["byol"] : var.fgtsku["payg"]
    version   = var.fgtversion
  }

  plan {
    name      = var.license_type == "byol" ? var.fgtsku["byol"] : var.fgtsku["payg"]
    publisher = var.publisher
    product   = var.fgtoffer
  }

  storage_os_disk {
    name              = "${var.prefix}-${var.site["id"]}-osDisk-fgt-passive"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-${var.site["id"]}-datadisk-fgt-passive"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.site["id"]}-fgt-passive"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.fgt-passive_all-config.0.rendered
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

data "template_file" "fgt-passive_all-config" {
  count    = var.fgt-subnet_cidrs != null && var.fgt-passive-ni_ids != null && var.site["ha"] ? 1 : 0
  template = file("${path.module}/templates/fgt-all.conf")
  vars = {
    type           = var.license_type
    license_file   = var.license-passive
    fgt_id         = "${var.site["id"]}-passive"
    api_key        = random_string.api_key.result
    rsa-public-key = var.rsa-public-key
    adminusername  = var.adminusername
    admin_port     = var.admin_port
    admin_cidr     = var.admin_cidr
    site_cidr      = var.site["cidr"]

    port1_ip   = cidrhost(var.fgt-subnet_cidrs["mgmt"], 11)
    port1_mask = cidrnetmask(var.fgt-subnet_cidrs["mgmt"])
    port1_gw   = cidrhost(var.fgt-subnet_cidrs["mgmt"], 1)
    port2_ip   = cidrhost(var.fgt-subnet_cidrs["public"], 11)
    port2_mask = cidrnetmask(var.fgt-subnet_cidrs["public"])
    port2_gw   = cidrhost(var.fgt-subnet_cidrs["public"], 1)
    port3_ip   = cidrhost(var.fgt-subnet_cidrs["private"], 11)
    port3_mask = cidrnetmask(var.fgt-subnet_cidrs["private"])
    port3_gw   = cidrhost(var.fgt-subnet_cidrs["private"], 1)

    fgt_ha-config    = data.template_file.fgt_ha-passive-config.0.rendered
    fgt_sdwan-config = var.hubs != null ? join("\n", data.template_file.fgt_sdwan-config.*.rendered) : ""
    fgt_bgp-config   = var.site != null ? data.template_file.fgt_bgp-config.rendered : ""
    fgt_sdn-config   = var.subscription_id != "" && var.tenant_id != "" && var.client_id != "" && var.client_secret != "" ? data.template_file.fgt_sdn-config.0.rendered : ""
    fgt_vwan-config  = var.vhub_peer != null ? data.template_file.fgt_vwan-config.rendered : ""
  }
}

data "template_file" "fgt_ha-passive-config" {
  count    = var.fgt-passive-ni_ids != null && var.site["ha"] ? 1 : 0
  template = file("${path.module}/templates/fgt-ha.conf")
  vars = {
    fgt_priority = 100
    port_gw      = cidrhost(var.fgt-subnet_cidrs["mgmt"], 1)
    peerip       = cidrhost(var.fgt-subnet_cidrs["mgmt"], 10)
  }
}