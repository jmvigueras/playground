resource "azurerm_virtual_machine" "regiona-fgt-passive" {
  name                         = "${var.prefix}-fgt-passive"
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
    id        = null
  }

  plan {
    name      = var.license_type == "byol" ? var.fgtsku["byol"] : var.fgtsku["payg"]
    publisher = var.publisher
    product   = var.fgtoffer
  }

  storage_os_disk {
    name              = "${var.prefix}-osDisk-fgt-passive"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-datadisk-fgt-passive"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "fgt-passive"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.passiveFortiGate.rendered
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

data "template_file" "passiveFortiGate" {
  template = file("${path.module}/fgt.conf")
  vars = {
    type            = var.license_type
    license_file    = var.license-passive
    fgt_id          = "${var.hub["id"]}-Passive"
    fgt_priority    = 100
    api_key         = random_string.api_key.result
    
    port1_ip        = cidrhost(var.fgt-subnet_cidrs["mgmt"],11)
    port1_mask      = cidrnetmask(var.fgt-subnet_cidrs["mgmt"])
    port1_gw        = cidrhost(var.fgt-subnet_cidrs["mgmt"],1)
    port2_ip        = cidrhost(var.fgt-subnet_cidrs["public"],11)
    port2_mask      = cidrnetmask(var.fgt-subnet_cidrs["public"])
    port2_gw        = cidrhost(var.fgt-subnet_cidrs["public"],1)
    port2_name      = var.fgt-passive-ni_names[1]
    port3_ip        = cidrhost(var.fgt-subnet_cidrs["private"],11)
    port3_mask      = cidrnetmask(var.fgt-subnet_cidrs["private"])
    port3_gw        = cidrhost(var.fgt-subnet_cidrs["private"],1)

    peerip          = cidrhost(var.fgt-subnet_cidrs["mgmt"],10)
    gwlb_ip         = var.gwlb_ip
    
    tenant          = var.tenant_id
    subscription    = var.subscription_id
    clientid        = var.client_id
    clientsecret    = var.client_secret
    admin_port      = var.admin_port
    admin_cidr      = var.admin_cidr
    rsg             = var.resourcegroup_name

    spoke-1_cidr        = var.spoke-vnet_cidrs["spoke-1"]
    spoke-2_cidr        = var.spoke-vnet_cidrs["spoke-2"]
    spoke-1_subnet1     = var.spoke-subnet_cidrs["spoke-1_subnet1"]
    spoke-1_subnet2     = var.spoke-subnet_cidrs["spoke-1_subnet2"]
    spoke-2_subnet1     = var.spoke-subnet_cidrs["spoke-2_subnet1"]
    spoke-2_subnet2     = var.spoke-subnet_cidrs["spoke-2_subnet2"]

    sites_bgp-asn           = var.sites_bgp-asn
    hub_bgp-asn             = var.hub["bgp-asn"]
    hub_bgp-id              = var.hub["bgp-id"]
    hub_vxlan-ip1           = var.hub["vxlan-ip1"]
    hub_advpn-ip1           = cidrhost(var.hub["advpn-net"],1)
    hub_advpn-ip2           = cidrhost(var.hub["advpn-net"],2)
    hub_advpn-net           = var.hub["advpn-net"]
    hub-peer_bgp-asn        = var.hub-peer["bgp-asn"]
    hub-peer_public-ip1     = var.hub-peer["public-ip1"]
    hub-peer_vxlan-ip1      = var.hub-peer["vxlan-ip1"]
    
    cluster-public-ip         = var.cluster-public-ip_name
    rt-private_name           = var.rt-private_name
    rt-private_route_0        = "default"
    rs-spoke1_ip1             = var.rs-spoke["rs1_ip1"]
    rs-spoke1_ip2             = var.rs-spoke["rs1_ip2"]
    rs-spoke1_bgp-asn         = var.rs-spoke["rs1_bgp-asn"]
    rs-spoke2_ip1             = var.rs-spoke["rs2_ip1"]
    rs-spoke2_ip2             = var.rs-spoke["rs2_ip2"]
    rs-spoke2_bgp-asn         = var.rs-spoke["rs2_bgp-asn"]

    spokes-onprem-cidr        = var.spokes-onprem-cidr
    advpn-ipsec-psk           = var.advpn-ipsec-psk
  }
}
