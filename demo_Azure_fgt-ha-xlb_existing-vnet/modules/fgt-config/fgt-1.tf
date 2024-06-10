#-------------------------------------------------------------------------------------------------------------
# FGT ACTIVE VM
#-------------------------------------------------------------------------------------------------------------
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

data "template_file" "fgt_active" {
  template = file("${path.module}/templates/fgt-all.conf")

  vars = {
    fgt_id         = var.config_spoke ? "${var.spoke["id"]}-1" : "${var.hub[0]["id"]}-1"
    admin_port     = var.admin_port
    admin_cidr     = var.admin_cidr
    adminusername  = "admin"
    type           = var.license_type
    license_file   = var.license_file_1
    fortiflex_token = var.fortiflex_token_1
    rsa-public-key = trimspace(var.rsa-public-key)
    api_key        = var.api_key == null ? random_string.api_key.result : var.api_key

    public_port  = var.public_port
    public_ip    = var.fgt-active-ni_ips["public"]
    public_mask  = cidrnetmask(var.subnet_cidrs["public"])
    public_gw    = cidrhost(var.subnet_cidrs["public"], 1)
    private_port = var.private_port
    private_ip   = var.fgt-active-ni_ips["private"]
    private_mask = cidrnetmask(var.subnet_cidrs["private"])
    private_gw   = cidrhost(var.subnet_cidrs["private"], 1)
    mgmt_port    = var.mgmt_port
    mgmt_ip      = var.fgt-active-ni_ips["mgmt"]
    mgmt_mask    = cidrnetmask(var.subnet_cidrs["mgmt"])
    mgmt_gw      = cidrhost(var.subnet_cidrs["mgmt"], 1)

    fgt_sdn-config        = data.template_file.fgt_1_sdn-config.rendered
    fgt_standalone-config = !var.config_fgsp ? !var.config_fgcp ? data.template_file.fgt_standalone-config.rendered : "" : ""
    fgt_ha-fgcp-config    = var.config_fgcp ? data.template_file.fgt_ha-fgcp-active-config.rendered : ""
    fgt_ha-fgsp-config    = var.config_fgsp ? data.template_file.fgt_ha-fgsp-active-config.rendered : ""
    fgt_bgp-config        = data.template_file.fgt_bgp-config.rendered
    fgt_static-config     = var.vpc-spoke_cidr != null ? data.template_file.fgt_static-config.rendered : ""
    fgt_sdwan-config      = var.config_spoke ? join("\n", data.template_file.fgt_sdwan-config.*.rendered) : ""
    fgt_vpn-config        = var.config_hub ? join("\n", data.template_file.fgt_vpn-active-config.*.rendered) : ""
    fgt_vxlan-config      = var.config_vxlan ? var.config_fgsp ? join("\n", local.fgt_1_fgsp_vxlan_config) :  join("\n", data.template_file.fgt_vxlan-active-config.*.rendered) : ""
    fgt_vhub-config       = var.config_vhub ? data.template_file.fgt_vhub-config.0.rendered : ""
    fgt_ars-config        = var.config_ars ? data.template_file.fgt_ars-config.0.rendered : ""
    fgt_gwlb-vxlan-config = var.config_gwlb-vxlan ? data.template_file.fgt_gwlb-vxlan-config.rendered : ""
    fgt_fmg-config        = var.config_fmg ? data.template_file.fgt_1_fmg-config.rendered : ""
    fgt_faz-config        = var.config_faz ? data.template_file.fgt_1_faz-config.rendered : ""
    fgt_xlb-config        = var.config_xlb ? data.template_file.fgt_xlb-config.rendered : ""
    fgt_extra-config      = var.fgt_active_extra-config
  }
}

data "template_file" "fgt_1_sdn-config" {
  template = file("${path.module}/templates/az_fgt-sdn.conf")
  vars = {
    tenant              = var.tenant_id != null ? var.tenant_id : ""
    subscription        = var.subscription_id != null ? var.subscription_id : ""
    clientid            = var.client_id != null ? var.client_id : ""
    clientsecret        = var.client_secret != null ? var.client_secret  : ""
    resource_group_name = var.resource_group_name != null ? var.resource_group_name : ""
    
    fgt_ni      = var.fgt-active-ni_names != null ? var.fgt-active-ni_names["public"] : ""
    cluster_pip = var.cluster_pip != null ? var.cluster_pip : ""
    route_table = var.route_table != null ? var.route_table : ""
    fgt_ip      = var.fgt-active-ni_ips["private"]
  }
}

data "template_file" "fgt_ha-fgcp-active-config" {
  template = file("${path.module}/templates/fgt-ha-fgcp.conf")
  vars = {
    fgt_priority = 200
    mgmt_port    = var.mgmt_port
    ha_port      = var.ha_port
    mgmt_gw      = cidrhost(var.subnet_cidrs["mgmt"], 1)
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

data "template_file" "fgt_standalone-config" {
  template = file("${path.module}/templates/fgt-standalone.conf")
  vars = {
    mgmt_port = var.mgmt_port
    mgmt_gw   = cidrhost(var.subnet_cidrs["mgmt"], 1)
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

data "template_file" "fgt_vpn-active-config" {
  count    = length(var.hub)
  template = file("${path.module}/templates/fgt-vpn.conf")
  vars = {
    hub_private_ip        = cidrhost(var.hub[count.index]["vpn_cidr"], 1)
    network_id            = var.hub[count.index]["network_id"]
    ike_version           = var.hub[count.index]["ike_version"]
    dpd_retryinterval     = var.hub[count.index]["dpd_retryinterval"]
    local_id              = var.hub[count.index]["id"]
    local_bgp_asn         = var.hub[count.index]["bgp_asn_hub"]
    local_router-id       = var.fgt-active-ni_ips["mgmt"]
    local_network         = var.hub[count.index]["cidr"]
    local_gw              = var.hub[count.index]["local_gw"]
    mode_cfg              = var.hub[count.index]["mode_cfg"]
    site_private_ip_start = cidrhost(var.hub[count.index]["vpn_cidr"], 2)
    site_private_ip_end   = cidrhost(var.hub[count.index]["vpn_cidr"], 14)
    site_private_ip_mask  = cidrnetmask(var.hub[count.index]["vpn_cidr"])
    site_bgp_asn          = var.hub[count.index]["bgp_asn_spoke"]
    vpn_psk               = var.hub[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hub[count.index]["vpn_psk"]
    vpn_cidr              = var.hub[count.index]["vpn_cidr"]
    vpn_port              = var.ports[var.hub[count.index]["vpn_port"]]
    vpn_name              = "vpn-${var.hub[count.index]["vpn_port"]}"
    private_port          = var.ports["private"]
    route_map_out         = "rm_out_aspath_0"
    count                 = count.index + 1
  }
}

data "template_file" "fgt_bgp-config" {
  template = file("${path.module}/templates/fgt-bgp.conf")
  vars = {
    bgp_asn   = var.config_hub ? var.hub[0]["bgp_asn_hub"] : var.config_spoke ? var.spoke["bgp_asn"] : var.bgp_asn_default
    router_id = var.fgt-active-ni_ips["mgmt"]
  }
}

locals {
  fgt_1_fgsp_vxlan_config =  compact([for i, peer_vxlan_config in data.template_file.fgt_vxlan-active-config.*.rendered  : i % 2 != 0 ? null : peer_vxlan_config])
}

data "template_file" "fgt_vxlan-active-config" {
  count    = length(var.hub_peer_vxlan)
  template = file("${path.module}/templates/fgt-vxlan.conf")
  vars = {
    vni             = var.hub_peer_vxlan[count.index]["vni"]
    external_ip     = var.hub_peer_vxlan[count.index]["external_ip"]
    remote_ip       = var.hub_peer_vxlan[count.index]["remote_ip"]
    local_ip        = var.hub_peer_vxlan[count.index]["local_ip"]
    bgp_asn         = var.hub_peer_vxlan[count.index]["bgp_asn"]
    vxlan_port      = var.ports[var.hub_peer_vxlan[count.index]["vxlan_port"]]
    private_port    = var.ports["private"]
    vpn_name        = "vpn-${var.ports[var.hub_peer_vxlan[count.index]["vxlan_port"]]}"
    vxlan_name      = var.hub_peer_vxlan_name
    route_map_out   = "rm_out_hub_to_hub_0"
    local_router-id = var.fgt-active-ni_ips["mgmt"]
    local_bgp_asn   = var.config_hub ? var.hub[0]["bgp_asn_hub"] : var.config_spoke ? var.spoke["bgp_asn"] : var.bgp_asn_default
    count           = count.index + 1
  }
}

data "template_file" "fgt_static-config" {
  template = templatefile("${path.module}/templates/fgt-static.conf", {
    vpc-spoke_cidr = var.vpc-spoke_cidr
    port           = var.private_port
    gw             = cidrhost(var.subnet_cidrs["private"], 1)
  })
}

data "template_file" "fgt_gwlb-vxlan-config" {
  template = file("${path.module}/templates/az_fgt-gwlb-vxlan.conf")
  vars = {
    gwlb_ip      = var.gwlb_ip
    vdi_ext      = var.gwlb_vxlan["vdi_ext"]
    vdi_int      = var.gwlb_vxlan["vdi_int"]
    port_ext     = var.gwlb_vxlan["port_ext"]
    port_int     = var.gwlb_vxlan["port_int"]
    private_port = var.private_port
  }
}

data "template_file" "fgt_vhub-config" {
  count = var.config_fgsp ? 2 : 1
  template = templatefile("${path.module}/templates/az_fgt-vhub.conf", {
    vhub_peer       = var.vhub_peer
    vhub_bgp_asn    = var.vhub_bgp_asn[0]
    local_bgp_asn   = var.config_hub ? var.hub[0]["bgp_asn_hub"] : var.config_spoke ? var.spoke["bgp_asn"] : var.bgp_asn_default
    local_router-id = var.fgt-active-ni_ips["mgmt"]
    route_map_out   = "rm_out_aspath_${count.index}"
  })
}

data "template_file" "fgt_ars-config" {
  count = var.config_fgsp ? 2 : 1
  template = templatefile("${path.module}/templates/az_fgt-ars.conf", {
    rs_peers        = var.rs_peer
    rs_bgp_asn      = var.rs_bgp_asn[0]
    local_bgp_asn   = var.config_hub ? var.hub[0]["bgp_asn_hub"] : var.config_spoke ? var.spoke["bgp_asn"] : var.bgp_asn_default
    local_router-id = var.fgt-active-ni_ips["mgmt"]
    route_map_out   = "rm_out_aspath_${count.index}"
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

data "template_file" "fgt_xlb-config" {
  template = templatefile("${path.module}/templates/az_fgt-xlb.conf", {
    private_port = var.private_port
    public_port  = var.public_port
    ilb_ip       = var.ilb_ip
    elb_ip       = var.elb_ip
  })
}
