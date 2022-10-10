// Create Fortgate VM site1

resource "azurerm_virtual_machine" "fgt-site" {
  name                         = "${var.prefix}-fgt-site-${var.site["site_id"]}"
  location                     = var.location
  resource_group_name          = var.resourcegroup_name

  network_interface_ids        = [
    azurerm_network_interface.ni-site-port1.id,
    azurerm_network_interface.ni-site-port2.id,
    azurerm_network_interface.ni-site-port3.id
  ]
  primary_network_interface_id = azurerm_network_interface.ni-site-port1.id
  vm_size                      = var.size

  lifecycle {
    ignore_changes = [os_profile]
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.fgtoffer
    sku       = var.license_type == "byol" ? var.fgtsku["byol"] : var.fgtsku["payg"]
    version   = var.fgtversion
    id        = null
  }

  plan {
    name      = var.license_type == "byol" ? var.fgtsku["byol"] : var.fgtsku["payg"]
    publisher = var.publisher
    product   = var.fgtoffer
  }

  storage_os_disk {
    name              = "${var.prefix}-osDisk-fgt-site-${var.site["site_id"]}"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-datadisk-fgt-site-${var.site["site_id"]}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "fgt-site-${var.site["site_id"]}"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.siteFortiGate.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage-account_endpoint
  }

  tags = {
    environment = var.tag_env
  }
}

data "template_file" "siteFortiGate" {
  template = file("${path.module}/fgt.conf")
  vars = {
    type            = var.license_type
    license_file    = var.license-site
    admin_port      = var.admin_port
    admin_cidr      = var.admin_cidr
    site_id         = var.site["site_id"]
    
    port1_ip   = cidrhost(cidrsubnet(var.site["cidr"],4,1),10)
    port1_mask = cidrnetmask(cidrsubnet(var.site["cidr"],4,1))
    port1_net  = cidrsubnet(var.site["cidr"],4,1)
    port1_gw   = cidrhost(cidrsubnet(var.site["cidr"],4,1),1)

    port2_ip   = cidrhost(cidrsubnet(var.site["cidr"],4,2),10)
    port2_mask = cidrnetmask(cidrsubnet(var.site["cidr"],4,2))
    port2_net  = cidrsubnet(var.site["cidr"],4,2)
    port2_gw   = cidrhost(cidrsubnet(var.site["cidr"],4,2),1)

    port3_ip   = cidrhost(cidrsubnet(var.site["cidr"],4,3),10)
    port3_mask = cidrnetmask(cidrsubnet(var.site["cidr"],4,3))
    port3_net  = cidrsubnet(var.site["cidr"],4,3)
    port3_gw   = cidrhost(cidrsubnet(var.site["cidr"],4,3),1)

    spoke1-net           = cidrsubnet(var.site["cidr"],4,8)

    site_bgp-asn         = var.site["bgp-asn"]
    site_advpn-ip1       = var.site["advpn-ip1"]
    site_advpn-ip2       = var.site["advpn-ip2"]

    hub1_bgp-asn         = var.hub1["bgp-asn"]
    hub1_public-ip1      = var.hub1["public-ip1"]
    hub1_advpn-ip1       = var.hub1["advpn-ip1"]
    hub1_hck-srv-ip1     = var.hub1["hck-srv-ip1"]
    hub1_hck-srv-ip2     = var.hub1["hck-srv-ip2"]
    hub1_hck-srv-ip3     = var.hub1["hck-srv-ip3"]
    hub1_cidr            = var.hub1["cidr"]
    hub1_advpn-psk       = var.hub1["advpn-psk"]

    hub2_bgp-asn         = var.hub2["bgp-asn"]
    hub2_public-ip1      = var.hub2["public-ip1"]
    hub2_advpn-ip1       = var.hub2["advpn-ip1"]
    hub2_hck-srv-ip1     = var.hub2["hck-srv-ip1"]
    hub2_hck-srv-ip2     = var.hub2["hck-srv-ip2"]
    hub2_hck-srv-ip3     = var.hub2["hck-srv-ip3"]
    hub2_cidr            = var.hub2["cidr"]
    hub2_advpn-psk       = var.hub2["advpn-psk"]
  }
}


