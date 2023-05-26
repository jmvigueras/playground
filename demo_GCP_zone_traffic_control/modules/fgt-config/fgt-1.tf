##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################

# Data template fgt_1
data "template_file" "fgt_active" {
  template = file("${path.module}/templates/fgt-all.conf")

  vars = {
    fgt_id         = var.config_spoke ? "${var.spoke["id"]}-1" : "${var.hub["id"]}-1"
    admin_port     = var.admin_port
    admin_cidr     = var.admin_cidr
    adminusername  = "admin"
    type           = var.license_type
    license_file   = var.license_file_1
    rsa-public-key = trimspace(var.rsa-public-key)
    api_key        = var.api_key == null ? random_string.api_key.result : var.api_key

    public_port  = var.public_port
    public_ip    = var.fgt-active-ni_ips["public"]
    public_mask  = "255.255.255.255"
    public_gw    = cidrhost(var.subnet_cidrs["public"], 1)
    public_cidr  = var.subnet_cidrs["public"]
    private_port = var.private_port
    private_ip   = var.fgt-active-ni_ips["private"]
    private_mask = "255.255.255.255"
    private_gw   = cidrhost(var.subnet_cidrs["private"], 1)
    private_cidr = var.subnet_cidrs["private"]
    mgmt_port    = var.mgmt_port
    mgmt_ip      = var.fgt-active-ni_ips["mgmt"]
    mgmt_mask    = "255.255.255.255"
    mgmt_gw      = cidrhost(var.subnet_cidrs["mgmt"], 1)
    mgmt_cidr    = var.subnet_cidrs["mgmt"]

    fgt_sdn-config         = data.template_file.fgt_sdn-config.rendered
    fgt_ha-fgcp-config     = var.config_fgcp ? data.template_file.fgt_ha-fgcp-active-config.rendered : ""
    fgt_ha-fgsp-config     = var.config_fgsp ? data.template_file.fgt_ha-fgsp-active-config.rendered : ""
    fgt_bgp-config         = var.config_spoke ? data.template_file.fgt_spoke_bgp-config.rendered : var.config_hub ? data.template_file.fgt_hub_bgp-config.rendered : ""
    fgt_static-config      = var.vpc-spoke_cidr != null ? data.template_file.fgt_active_static-config.rendered : ""
    fgt_sdwan-config       = var.config_spoke ? join("\n", data.template_file.fgt_sdwan-config.*.rendered) : ""
    fgt_vxlan-config       = var.config_vxlan ? data.template_file.fgt_vxlan-config.rendered : ""
    fgt_vpn-config         = var.config_hub ? data.template_file.fgt_vpn-config.0.rendered : ""
    fgt_fmg-config         = var.config_fmg ? data.template_file.fgt_1_fmg-config.rendered : ""
    fgt_faz-config         = var.config_faz ? data.template_file.fgt_1_faz-config.rendered : ""
    fgt_ncc-config         = var.config_ncc ? data.template_file.fgt_ncc-config.rendered : ""
    fgt_xlb-config         = var.config_xlb ? data.template_file.fgt_xlb-config.rendered : ""
    fgt_extra-config       = var.fgt_active_extra-config
  }
}

data "template_file" "fgt_sdn-config" {
  template = templatefile("${path.module}/templates/gcp_fgt-sdn.conf", {
    cluster_pips = var.config_fgcp && var.cluster_pips != null ?  var.cluster_pips : null
    route_tables = var.config_fgcp && var.route_tables != null ?  var.route_tables : null
  })
}

data "template_file" "fgt_ha-fgcp-active-config" {
  template = file("${path.module}/templates/gcp_fgt-ha-fgcp.conf")
  vars = {
    fgt_priority = 200
    ha_port      = var.mgmt_port
    ha_gw        = cidrhost(var.subnet_cidrs["mgmt"], 1)
    ha_mask      = cidrnetmask(var.subnet_cidrs["mgmt"])
    peerip       = var.fgt-passive-ni_ips["mgmt"]
  }
}

data "template_file" "fgt_ha-fgsp-active-config" {
  template = file("${path.module}/templates/fgt-ha-fgsp.conf")
  vars = {
    mgmt_port     = var.mgmt_port
    mgmt_gw       = cidrhost(var.subnet_cidrs["mgmt"], 1)
    peerip        = var.fgt-passive-ni_ips["mgmt"]
    master_secret = random_string.fgsp_auto-config_secret.result
    master_ip     = ""
  }
}

data "template_file" "fgt_sdwan-config" {
  count    = var.hubs != null ? length(var.hubs) : 0
  template = file("${path.module}/templates/fgt-sdwan.conf")
  vars = {
    hub_id            = var.hubs[count.index]["id"]
    hub_ipsec_id      = "${var.hubs[count.index]["id"]}_ipsec_${count.index + 1}"
    hub_vpn_psk       = var.hubs[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hubs[count.index]["vpn_psk"]
    hub_external_ip   = var.hubs[count.index]["external_ip"]
    hub_private_ip    = var.hubs[count.index]["hub_ip"]
    site_private_ip   = var.hubs[count.index]["site_ip"]
    hub_bgp_asn       = var.hubs[count.index]["bgp_asn"]
    hck_ip            = var.hubs[count.index]["hck_ip"]
    hub_cidr          = var.hubs[count.index]["cidr"]
    network_id        = var.hubs[count.index]["network_id"]
    ike_version       = var.hubs[count.index]["ike_version"]
    dpd_retryinterval = var.hubs[count.index]["dpd_retryinterval"]
    local_id          = var.spoke["id"]
    local_bgp_asn     = var.spoke["bgp_asn"]
    local_router_id   = var.fgt-active-ni_ips["mgmt"]
    local_network     = var.spoke["cidr"]
    sdwan_port        = var.ports[var.hubs[count.index]["sdwan_port"]]
    private_port      = var.ports["private"]
    count             = count.index + 1
  }
}

data "template_file" "fgt_vpn-config" {
  count    = var.config_fgsp ? 2 : 1
  template = file("${path.module}/templates/fgt-vpn.conf")
  vars = {
    hub_private-ip        = cidrhost(cidrsubnet(var.hub["vpn_cidr"], 1, count.index), 1)
    network_id            = var.hub["network_id"]
    ike-version           = var.hub["ike-version"]
    dpd-retryinterval     = var.hub["dpd-retryinterval"]
    localid               = var.hub["id"]
    mode-cfg              = var.hub["mode-cfg"]
    site_private-ip_start = cidrhost(cidrsubnet(var.hub["vpn_cidr"], 1, count.index), 2)
    site_private-ip_end   = cidrhost(cidrsubnet(var.hub["vpn_cidr"], 1, count.index), 14)
    site_private-ip_mask  = cidrnetmask(cidrsubnet(var.hub["vpn_cidr"], 1, count.index))
    vpn_psk               = var.hub["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hub["vpn_psk"]
    bgp-asn_spoke         = var.hub["bgp-asn_spoke"]
    vpn_cidr              = cidrsubnet(var.hub["vpn_cidr"], 1, count.index)
    vpn_port              = var.public_port
    private_port          = var.private_port
  }
}

data "template_file" "fgt_spoke_bgp-config" {
  template = file("${path.module}/templates/fgt-bgp.conf")
  vars = {
    bgp-asn   = var.spoke["bgp_asn"]
    router-id = var.fgt-active-ni_ips["mgmt"]
    network   = var.spoke["cidr"]
    role      = "spoke"
  }
}

data "template_file" "fgt_hub_bgp-config" {
  template = file("${path.module}/templates/fgt-bgp.conf")
  vars = {
    bgp-asn   = var.hub["bgp-asn_hub"]
    router-id = var.fgt-active-ni_ips["mgmt"]
    network   = var.hub["cidr"]
    role      = "hub"
  }
}

data "template_file" "fgt_vxlan-config" {
  template = file("${path.module}/templates/fgt-vxlan.conf")
  vars = {
    vni          = var.hub-peer_vxlan["vni"]
    public-ip    = var.hub-peer_vxlan["public-ip"]
    remote-ip    = var.hub-peer_vxlan["remote-ip"]
    local-ip     = var.hub-peer_vxlan["local-ip"]
    bgp-asn      = var.hub-peer_vxlan["bgp-asn"]
    vxlan_port   = var.public_port
    private_port = var.private_port
  }
}

data "template_file" "fgt_active_static-config" {
  template = templatefile("${path.module}/templates/fgt-static.conf", {
    vpc-spoke_cidr = var.vpc-spoke_cidr
    port           = var.private_port
    gw             = cidrhost(var.subnet_cidrs["private"], 1)
  })
}

data "template_file" "fgt_1_faz-config" {
  template = file("${path.module}/templates/fgt-faz.conf")
  vars = {
    ip                      = var.faz_ip
    sn                      = var.faz_sn
    source-ip               = var.faz_fgt-1_source-ip
    interface-select-method = var.faz_interface-select-method
  }
}

data "template_file" "fgt_1_fmg-config" {
  template = file("${path.module}/templates/fgt-fmg.conf")
  vars = {
    ip                      = var.fmg_ip
    sn                      = var.fmg_sn
    source-ip               = var.fmg_fgt-1_source-ip
    interface-select-method = var.fmg_interface-select-method
  }
}

data "template_file" "fgt_ncc-config" {
  template = templatefile("${path.module}/templates/gcp_fgt-ncc.conf", {
    ncc_peers    = var.ncc_peers
    ncc_bgp-asn  = var.ncc_bgp-asn
  })
}

data "template_file" "fgt_xlb-config" {
  template = templatefile("${path.module}/templates/gcp_fgt-xlb.conf", {
    private_port = var.private_port
    ilb_ip       = var.ilb_ip
  })
}



#------------------------------------------------------------------------------------
# Generate random strings
#------------------------------------------------------------------------------------
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}

# Create new random FGSP secret
resource "random_string" "fgsp_auto-config_secret" {
  length  = 10
  special = false
  numeric = true
}

# Create new random FGSP secret
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}