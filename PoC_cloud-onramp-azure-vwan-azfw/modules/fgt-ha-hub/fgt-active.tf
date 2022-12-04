#------------------------------------------------------------------------------------------------------------
# FGT ACTIVE VM
#------------------------------------------------------------------------------------------------------------
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "advpn-ipsec-psk" {
  length  = 30
  special = false
  numeric = true
}

# Create and attach the eip to the units
resource "azurerm_virtual_machine" "fgt-active" {
  count                        = var.fgt-active-ni_ids != null ? 1 : 0
  name                         = "${var.prefix}-${var.hub["id"]}-fgt-active"
  location                     = var.location
  resource_group_name          = var.resourcegroup_name
  network_interface_ids        = var.fgt-active-ni_ids
  primary_network_interface_id = var.fgt-active-ni_ids[0]
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
    name              = "${var.prefix}-${var.hub["id"]}-osDisk-fgt-active"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-${var.hub["id"]}-datadisk-fgt-active"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "fgt-active"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.fgt-active_all-config.0.rendered
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

data "template_file" "fgt-active_all-config" {
  count    = var.fgt-subnet_cidrs != null ? 1 : 0
  template = file("${path.module}/templates/fgt-all.conf")
  vars = {
    type           = var.license_type
    license_file   = var.license-active
    fgt_id         = "${var.hub["id"]}-active"
    api_key        = random_string.api_key.result
    rsa-public-key = var.rsa-public-key
    adminusername  = var.adminusername
    admin_port     = var.admin_port
    admin_cidr     = var.admin_cidr
    hub_cidr       = var.hub["cidr"]

    port1_ip   = cidrhost(var.fgt-subnet_cidrs["mgmt"], 10)
    port1_mask = cidrnetmask(var.fgt-subnet_cidrs["mgmt"])
    port1_gw   = cidrhost(var.fgt-subnet_cidrs["mgmt"], 1)
    port2_ip   = cidrhost(var.fgt-subnet_cidrs["public"], 10)
    port2_mask = cidrnetmask(var.fgt-subnet_cidrs["public"])
    port2_gw   = cidrhost(var.fgt-subnet_cidrs["public"], 1)
    port3_ip   = cidrhost(var.fgt-subnet_cidrs["private"], 10)
    port3_mask = cidrnetmask(var.fgt-subnet_cidrs["private"])
    port3_gw   = cidrhost(var.fgt-subnet_cidrs["private"], 1)

    fgt_advpn-config = var.hub != null ? data.template_file.fgt_advpn-config.rendered : ""
    fgt_ha-config    = data.template_file.fgt_ha-active-config.rendered
    fgt_bgp-config   = var.hub != null ? data.template_file.fgt_bgp-config.rendered : ""
    fgt_sdn-config   = var.subscription_id != "" && var.tenant_id != "" && var.client_id != "" && var.client_secret != "" ? data.template_file.fgt_sdn-config.0.rendered : ""
    fgt_vwan-config  = var.vhub_peer != null ? data.template_file.fgt_vwan-config.rendered : ""
  }
}

data "template_file" "fgt_ha-active-config" {
  template = file("${path.module}/templates/fgt-ha.conf")
  vars = {
    fgt_priority = 200
    port_gw      = cidrhost(var.fgt-subnet_cidrs["mgmt"], 1)
    peerip       = cidrhost(var.fgt-subnet_cidrs["mgmt"], 11)
  }
}

data "template_file" "fgt_bgp-config" {
  template = templatefile("${path.module}/templates/fgt-bgp.conf", {
    hub_advpn-ip1    = cidrhost(var.hub["advpn-net"], 1),
    hub_advpn-ip2    = cidrhost(var.hub["advpn-net"], 2),
    hub_advpn-net    = var.hub["advpn-net"],
    advpn-ipsec-psk  = random_string.advpn-ipsec-psk.result,
    hub_bgp-asn      = var.hub["bgp-asn"],
    hub_bgp-id       = cidrhost(var.hub["advpn-net"], 1),
    rs_peers         = var.rs_peers,
    rs_bgp-asn       = var.rs_bgp-asn,
    vhub_peer        = var.vhub_peer,
    vhub_bgp-asn     = var.vhub_bgp-asn,
    spoke_bgp-asn    = var.spoke_bgp-asn
    hub-peer_bgp-asn = var.hub-peer_vxlan["bgp-asn"]
    hub-peer_ip1     = var.hub-peer_vxlan["remote-ip1"]
  })
}

data "template_file" "fgt_sdn-config" {
  count    = var.subscription_id != "" && var.tenant_id != "" && var.client_id != "" && var.client_secret != "" ? 1 : 0
  template = file("${path.module}/templates/fgt-sdn.conf")
  vars = {
    tenant       = var.tenant_id
    subscription = var.subscription_id
    clientid     = var.client_id
    clientsecret = var.client_secret
    rsg          = var.resourcegroup_name
  }
}

data "template_file" "fgt_vwan-config" {
  template = templatefile("${path.module}/templates/fgt-vwan.conf", {
    vhub_peer    = var.vhub_peer
    vhub_bgp-asn = var.vhub_bgp-asn
    port3_gw     = cidrhost(var.fgt-subnet_cidrs["private"], 1)
  })
}

data "template_file" "fgt_advpn-config" {
  template = file("${path.module}/templates/fgt-advpn.conf")
  vars = {
    hub_advpn-ip1   = cidrhost(var.hub["advpn-net"], 1)
    hub_advpn-ip2   = cidrhost(var.hub["advpn-net"], 2)
    advpn-ipsec-psk = random_string.advpn-ipsec-psk.result
  }
}