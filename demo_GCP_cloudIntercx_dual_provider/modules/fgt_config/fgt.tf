##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################
# Data template fgt
data "template_file" "fgt" {
  template = file("${path.module}/templates/fgt-all.conf")

  vars = {
    fgt_id          = var.config_spoke ? "${var.spoke["id"]}" : "${var.hub[0]["id"]}"
    admin_port      = var.admin_port
    admin_cidr      = var.admin_cidr
    adminusername   = "admin"
    type            = var.license_type
    license_file    = var.license_file
    fortiflex_token = var.fortiflex_token
    rsa-public-key  = trimspace(var.rsa-public-key)
    api_key         = var.api_key == null ? random_string.api_key.result : var.api_key

    public_port  = var.public_port
    public_ip    = var.fgt_ni_ips["public"]
    public_mask  = "255.255.255.255"
    public_gw    = cidrhost(var.subnet_cidrs["public"], 1)
    public_cidr  = var.subnet_cidrs["public"]
    private_port = var.private_port
    private_ip   = var.fgt_ni_ips["private"]
    private_mask = "255.255.255.255"
    private_gw   = cidrhost(var.subnet_cidrs["private"], 1)
    private_cidr = var.subnet_cidrs["private"]

    fgt_sdn-config    = data.template_file.fgt_sdn-config.rendered
    fgt_bgp-config    = var.config_spoke ? data.template_file.fgt_spoke_bgp-config.rendered : var.config_hub ? data.template_file.fgt_hub_bgp-config.rendered : ""
    fgt_static-config = var.vpc-spoke_cidr != null ? data.template_file.fgt_static-config.rendered : ""
    fgt_sdwan-config  = var.config_spoke ? join("\n", data.template_file.fgt_sdwan-config.*.rendered) : ""
    fgt_vxlan-config  = var.config_vxlan ? data.template_file.fgt_vxlan-config.rendered : ""
    fgt_vpn-config    = var.config_hub ? join("\n", data.template_file.config_vpn.*.rendered) : ""
    fgt_fmg-config    = var.config_fmg ? data.template_file.fgt_fmg-config.rendered : ""
    fgt_faz-config    = var.config_faz ? data.template_file.fgt_faz-config.rendered : ""
    fgt_ncc-config    = var.config_ncc ? data.template_file.fgt_ncc-config.rendered : ""
    fgt_xlb-config    = var.config_xlb ? data.template_file.fgt_xlb-config.rendered : ""
    config_s2s        = var.config_s2s ? join("\n", data.template_file.config_s2s.*.rendered) : ""
    fgt_extra-config  = var.fgt_extra-config
  }
}

data "template_file" "fgt_sdn-config" {
  template = templatefile("${path.module}/templates/gcp_fgt-sdn.conf", {
    cluster_pips = var.cluster_pips != null ? var.cluster_pips : null
    route_tables = var.route_tables != null ? var.route_tables : null
  })
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
    local_router_id   = var.fgt_ni_ips["public"]
    local_network     = var.spoke["cidr"]
    local_gw          = lookup(var.hubs[count.index], "local_gw", "")
    sdwan_port        = var.ports[var.hubs[count.index]["sdwan_port"]]
    private_port      = var.ports["private"]
    count             = count.index + 1
  }
}

data "template_file" "config_vpn" {
  count    = length(var.hub)
  template = file("${path.module}/templates/fgt_vpn.conf")
  vars = {
    hub_private_ip        = cidrhost(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0), 1)
    hub_remote_ip         = cidrhost(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0), 2)
    network_id            = lookup(var.hub[count.index], "network_id", "1")
    ike_version           = lookup(var.hub[count.index], "ike_version", "2")
    dpd_retryinterval     = lookup(var.hub[count.index], "dpd_retryinterval", "10")
    local_id              = var.hub[count.index]["id"]
    local_network         = var.hub[count.index]["cidr"]
    local_gw              = lookup(var.hub[count.index], "local_gw", "")
    fgsp_sync             = var.config_fgsp
    mode_cfg              = lookup(var.hub[count.index], "mode_cfg", true)
    site_private_ip_start = cidrhost(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0), 3)
    site_private_ip_end   = cidrhost(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0), -2)
    site_private_ip_mask  = cidrnetmask(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0))
    site_bgp_asn          = var.hub[count.index]["bgp_asn_spoke"]
    vpn_psk               = var.hub[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hub[count.index]["vpn_psk"]
    vpn_cidr              = cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0)
    vpn_port              = var.ports[var.hub[count.index]["vpn_port"]]
    vpn_name              = "vpn-${count.index}-${var.hub[count.index]["vpn_port"]}"
    count                 = count.index + 1
    route_map_out         = lookup(var.hub[count.index], "route_map_out", "")
    route_map_in          = lookup(var.hub[count.index], "route_map_in", "")
    count                 = count.index + 1
  }
}

data "template_file" "fgt_spoke_bgp-config" {
  template = file("${path.module}/templates/fgt-bgp.conf")
  vars = {
    bgp-asn   = var.spoke["bgp_asn"]
    router-id = var.fgt_ni_ips["public"]
    network   = var.spoke["cidr"]
    role      = "spoke"
  }
}

data "template_file" "fgt_hub_bgp-config" {
  template = file("${path.module}/templates/fgt-bgp.conf")
  vars = {
    bgp-asn   = var.hub[0]["bgp_asn_hub"]
    router-id = var.fgt_ni_ips["public"]
    network   = var.hub[0]["cidr"]
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

data "template_file" "fgt_static-config" {
  template = templatefile("${path.module}/templates/fgt-static.conf", {
    vpc-spoke_cidr = var.vpc-spoke_cidr
    port           = var.private_port
    gw             = cidrhost(var.subnet_cidrs["private"], 1)
  })
}

data "template_file" "fgt_faz-config" {
  template = file("${path.module}/templates/fgt-faz.conf")
  vars = {
    ip                      = var.faz_ip
    sn                      = var.faz_sn
    source-ip               = var.faz_fgt-1_source-ip
    interface-select-method = var.faz_interface-select-method
  }
}

data "template_file" "fgt_fmg-config" {
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
    ncc_peers   = var.ncc_peers
    ncc_bgp-asn = var.ncc_bgp-asn
  })
}

data "template_file" "fgt_xlb-config" {
  template = templatefile("${path.module}/templates/gcp_fgt-xlb.conf", {
    private_port = var.private_port
    ilb_ip       = var.ilb_ip
  })
}

# Create Site to Site config with SDWAN
data "template_file" "config_s2s" {
  count    = length(var.s2s_peers)
  template = file("${path.module}/templates/fgt_site_to_site.conf")
  vars = {
    id                = var.s2s_peers[count.index]["id"]
    remote_gw         = var.s2s_peers[count.index]["remote_gw"]
    local_gw          = lookup(var.s2s_peers[count.index], "local_gw", "")
    local_bgp_asn     = var.config_spoke ? "${var.spoke["bgp_asn"]}" : var.config_hub ? "${var.hub[0]["bgp_asn_hub"]}" : var.bgp_asn_default
    local_router_id   = var.fgt_ni_ips["private"]
    vpn_intf_id       = "${var.s2s_peers[count.index]["id"]}_ipsec_${count.index + 1}"
    vpn_remote_ip     = var.s2s_peers[count.index]["vpn_remote_ip"]
    vpn_local_ip      = var.s2s_peers[count.index]["vpn_local_ip"]
    vpn_cidr_mask     = cidrnetmask(var.s2s_peers[count.index]["vpn_cidr"])
    vpn_psk           = var.s2s_peers[count.index]["vpn_psk"]
    vpn_port          = var.ports[var.s2s_peers[count.index]["vpn_port"]]
    network_id        = lookup(var.s2s_peers[count.index], "network_id", "11")
    ike_version       = lookup(var.s2s_peers[count.index], "ike_version", "2")
    dpd_retryinterval = lookup(var.s2s_peers[count.index], "dpd_retryinterval", "5")
    bgp_asn_remote    = var.s2s_peers[count.index]["bgp_asn_remote"]
    hck_ip            = var.s2s_peers[count.index]["hck_ip"]
    remote_cidr       = var.s2s_peers[count.index]["remote_cidr"]
    count             = count.index + 1
  }
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