##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################
# Data template fgt
data "template_file" "fgt" {
  template = file("${path.module}/templates/fgt_all.conf")

  vars = {
    fgt_id         = local.fgt_id
    admin_port     = var.admin_port
    admin_cidr     = var.admin_cidr
    adminusername  = "admin"
    rsa_public_key = trimspace(var.rsa_public_key)
    api_key        = var.api_key == null ? random_string.api_key.result : var.api_key

    config_basic      = data.template_file.config_basic.rendered
    config_interfaces = join("\n", data.template_file.config_interfaces.*.rendered)
    config_sdn        = data.template_file.config_sdn.rendered
    config_bgp        = data.template_file.config_bgp.rendered

    config_fw_policy = var.config_fw_policy ? data.template_file.config_fw_policy.rendered : ""
    config_fgcp      = var.config_fgcp ? data.template_file.config_fgcp.rendered : ""
    config_fgsp      = var.config_fgsp ? data.template_file.config_fgsp.rendered : ""
    config_scale     = var.config_auto_scale ? data.template_file.config_auto_scale.rendered : ""
    config_route     = var.static_route_cidrs != null ? data.template_file.config_route.rendered : ""
    config_sdwan     = var.config_spoke ? join("\n", data.template_file.config_sdwan.*.rendered) : ""
    config_tgw_gre   = var.config_tgw_gre ? data.template_file.config_tgw_gre.rendered : ""
    config_vxlan     = var.config_vxlan ? join("\n", data.template_file.config_vxlan.*.rendered, data.template_file.config_vxlan_bgp.*.rendered) : ""
    config_vpn       = var.config_hub ? join("\n", data.template_file.config_vpn.*.rendered) : ""
    config_fmg       = var.config_fmg ? data.template_file.config_fmg.rendered : ""
    config_faz       = var.config_faz ? data.template_file.config_faz.rendered : ""
    config_s2s       = var.config_s2s ? join("\n", data.template_file.config_s2s.*.rendered) : ""
    config_gwlb      = var.config_gwlb ? data.template_file.config_gwlb.rendered : ""
    config_extra     = var.config_extra
  }
}

data "template_file" "config_basic" {
  template = file("${path.module}/templates/fgt_basic.conf")
  vars = {
    license_type = var.license_type
    license_file = var.license_type
    flex_token   = var.fortiflex_token
    port         = local.port1_config["port"]
    ip           = local.port1_config["ip"]
    mask         = local.port1_config["mask"]
    gw           = local.port1_config["gw"]
  }
}

data "template_file" "config_fw_policy" {
  template = file("${path.module}/templates/fgt_fw_policy.conf")
  vars = {
    port = local.port1_config["port"]
  }
}

data "template_file" "config_interfaces" {
  count    = length(local.ports_config)
  template = file("${path.module}/templates/fgt_interface.conf")
  vars = {
    port  = local.ports_config[count.index]["port"]
    ip    = local.ports_config[count.index]["ip"]
    mask  = local.ports_config[count.index]["mask"]
    gw    = local.ports_config[count.index]["gw"]
    alias = local.ports_config[count.index]["tag"]
  }
}

data "template_file" "config_sdn" {
  template = file("${path.module}/templates/aws_fgt_sdn.conf")
}

data "template_file" "config_sdwan" {
  count    = var.hubs != null ? length(var.hubs) : 0
  template = file("${path.module}/templates/fgt_sdwan.conf")
  vars = {
    hub_id             = var.hubs[count.index]["id"]
    hub_ipsec_id       = "${var.hubs[count.index]["id"]}_ipsec_${count.index + 1}"
    hub_vpn_psk        = var.hubs[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hubs[count.index]["vpn_psk"]
    hub_external_ip    = lookup(var.hubs[count.index], "external_ip", "")
    hub_external_fqdn  = lookup(var.hubs[count.index], "external_fqdn", "")
    hub_private_ip     = var.hubs[count.index]["hub_ip"]
    site_private_ip    = lookup(var.hubs[count.index], "site_ip", "")
    hub_bgp_asn        = var.hubs[count.index]["bgp_asn"]
    hck_ip             = var.hubs[count.index]["hck_ip"]
    hub_cidr           = var.hubs[count.index]["cidr"]
    network_id         = lookup(var.hubs[count.index], "network_id", "1")
    ike_version        = lookup(var.hubs[count.index], "ike_version", "2")
    dpd_retryinterval  = lookup(var.hubs[count.index], "dpd_retryinterval", "5")
    local_id           = var.spoke["id"]
    local_bgp_asn      = var.spoke["bgp_asn"]
    local_router_id    = local.map_type_ip["public"]
    local_network      = var.spoke["cidr"]
    sdwan_port         = local.map_type_port[var.hubs[count.index]["sdwan_port"]]
    route_map_out      = lookup(var.hubs[count.index], "route_map_out", "rm_out_branch_sla_nok")
    route_map_out_pref = lookup(var.hubs[count.index], "route_map_out_pref", "rm_out_branch_sla_ok")
    route_map_in       = lookup(var.hubs[count.index], "route_map_in", "")
    count              = count.index + 1
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
    vpn_port              = local.map_type_port[var.hub[count.index]["vpn_port"]]
    vpn_name              = "vpn-${var.hub[count.index]["vpn_port"]}"
    count                 = count.index + 1
    route_map_out         = lookup(var.hub[count.index], "route_map_out", "")
    route_map_in          = lookup(var.hub[count.index], "route_map_in", "")
    count                 = count.index + 1
  }
}

data "template_file" "config_bgp" {
  template = file("${path.module}/templates/fgt_bgp.conf")
  vars = {
    bgp_asn        = var.config_hub ? var.hub[0]["bgp_asn_hub"] : var.config_spoke ? var.spoke["bgp_asn"] : var.bgp_asn_default
    community      = "10"
    remote_bgp_asn = var.config_hub ? var.hub[0]["bgp_asn_spoke"] : ""
    router_id      = local.map_type_ip[local.default_private_port]
  }
}

data "template_file" "config_vxlan" {
  count    = length(var.vxlan_peers)
  template = file("${path.module}/templates/fgt_vxlan.conf")
  vars = {
    vni         = lookup(var.vxlan_peers[count.index],"vni", "")
    external_ip = replace(lookup(var.vxlan_peers[count.index],"external_ip",""), ",", " ")
    local_ip    = lookup(var.vxlan_peers[count.index],"local_ip","")
    vxlan_port  = lookup(local.map_type_port, lookup(var.vxlan_peers[count.index],"vxlan_port", ""), "")
    count       = count.index + 1
  }
}

data "template_file" "config_vxlan_bgp" {
  count    = length(local.vxlan_peers_bgp)
  template = file("${path.module}/templates/fgt_vxlan_bgp.conf")
  vars = {
    remote_ip     = lookup(local.vxlan_peers_bgp[count.index],"remote_ip", "")
    bgp_asn       = lookup(local.vxlan_peers_bgp[count.index],"bgp_asn", "")
    route_map_out = lookup(local.vxlan_peers_bgp[count.index],"route_map_out", "")
    route_map_in  = lookup(local.vxlan_peers_bgp[count.index],"route_map_in", "")
  }
}

# Create Site to Site config with SDWAN
data "template_file" "config_s2s" {
  count    = length(var.s2s_peers)
  template = file("${path.module}/templates/fgt_site_to_site.conf")
  vars = {
    id                = var.s2s_peers[count.index]["id"]
    remote_gw         = var.s2s_peers[count.index]["remote_gw"]
    local_gw          = lookup(var.s2s_peers[count.index], "local_gw", "")
    vpn_intf_id       = "${var.s2s_peers[count.index]["id"]}_ipsec_${count.index + 1}"
    vpn_remote_ip     = var.s2s_peers[count.index]["vpn_remote_ip"]
    vpn_local_ip      = var.s2s_peers[count.index]["vpn_local_ip"]
    vpn_cidr_mask     = cidrnetmask(var.s2s_peers[count.index]["vpn_cidr"])
    vpn_psk           = var.s2s_peers[count.index]["vpn_psk"]
    vpn_port          = local.map_type_port[var.s2s_peers[count.index]["vpn_port"]]
    network_id        = lookup(var.s2s_peers[count.index], "network_id", "11")
    ike_version       = lookup(var.s2s_peers[count.index], "ike_version", "2")
    dpd_retryinterval = lookup(var.s2s_peers[count.index], "dpd_retryinterval", "5")
    bgp_asn_remote    = var.s2s_peers[count.index]["bgp_asn_remote"]
    hck_ip            = var.s2s_peers[count.index]["hck_ip"]
    remote_cidr       = var.s2s_peers[count.index]["remote_cidr"]
    count             = count.index + 1
  }
}

data "template_file" "config_route" {
  template = templatefile("${path.module}/templates/fgt_static.conf", {
    route_cidrs = var.static_route_cidrs
    port        = local.map_type_port[local.default_private_port]
    gw          = local.map_type_gw[local.default_private_port]
  })
}

data "template_file" "config_faz" {
  template = file("${path.module}/templates/fgt_faz.conf")
  vars = {
    ip                      = var.faz_ip
    sn                      = var.faz_sn
    source_ip               = var.faz_fgt_source_ip
    interface_select_method = var.faz_interface_select_method
  }
}

data "template_file" "config_fmg" {
  template = file("${path.module}/templates/fgt_fmg.conf")
  vars = {
    ip                      = var.fmg_ip
    sn                      = var.fmg_sn
    source_ip               = var.fmg_fgt_source_ip
    interface_select_method = var.fmg_interface_select_method
  }
}

data "template_file" "config_tgw_gre" {
  template = file("${path.module}/templates/aws_tgw_gre.conf")
  vars = {
    interface_name   = lookup(var.tgw_gre_peer, "gre_name", "gre-to-tgw")
    bgp_asn          = lookup(var.tgw_gre_peer, "tgw_bgp_asn", "65011")
    port             = local.map_type_port[local.default_private_port]
    tunnel_local_ip  = local.map_type_ip[local.default_private_port]
    tunnel_remote_ip = lookup(var.tgw_gre_peer, "tgw_ip", "")
    local_ip         = cidrhost(lookup(var.tgw_gre_peer, "inside_cidr", "169.254.101.0/29"), 1)
    remote_ip_1      = cidrhost(lookup(var.tgw_gre_peer, "inside_cidr", "169.254.101.0/29"), 2)
    remote_ip_2      = cidrhost(lookup(var.tgw_gre_peer, "inside_cidr", "169.254.101.0/29"), 3)
    route_map_in     = lookup(var.tgw_gre_peer, "route_map_in", "")
    route_map_out    = lookup(var.tgw_gre_peer, "route_map_out", "")
    local_bgp_asn    = var.config_hub ? var.hub[0]["bgp_asn_hub"] : var.config_spoke ? var.spoke["bgp_asn"] : var.bgp_asn_default
  }
}

data "template_file" "config_fgcp" {
  template = file("${path.module}/templates/aws_fgt_ha_fgcp.conf")
  vars = {
    fgt_priority = local.fgcp_priority
    ha_port      = local.fgcp_port
    ha_gw        = local.fgcp_gw
    peerip       = local.fgcp_peer_ip == null ? "" : local.fgcp_peer_ip
  }
}

data "template_file" "config_fgsp" {
  template = file("${path.module}/templates/fgt_ha_fgsp.conf")
  vars = {
    mgmt_port  = lookup(local.map_type_port, "mgmt", "")
    mgmt_gw    = lookup(local.map_type_gw, "mgmt", "")
    peers_list = join("\n", data.template_file.config_fgsp_peers.*.rendered)
    member_id  = local.ha_member_id
  }
}
data "template_file" "config_fgsp_peers" {
  count    = length(local.fgsp_peer_ips)
  template = file("${path.module}/templates/fgt_ha_fgsp_peers.conf")
  vars = {
    id   = count.index + 1
    ip   = local.fgsp_peer_ips[count.index]
    vdom = "root"
  }
}

data "template_file" "config_auto_scale" {
  template = file("${path.module}/templates/fgt_auto_scale.conf")
  vars = {
    sync_port     = lookup(local.map_type_port, var.auto_scale_sync_port, "")
    master_secret = var.auto_scale_secret
    master_ip     = local.fgsp_master_ip == null ? "" : local.fgsp_master_ip
  }
}

data "template_file" "config_gwlb" {
  template = templatefile("${path.module}/templates/aws_gwlb_geneve.conf", {
    geneve_int_name  = "geneve-${local.map_type_port[local.default_private_port]}"
    gwlbe_ip         = var.gwlbe_ip
    port             = local.map_type_port[local.default_private_port]
    inspection_cidrs = var.gwlb_inspection_cidrs
  })
}

#------------------------------------------------------------------------------------
# Generate random strings
#------------------------------------------------------------------------------------
# Create new random VPN PSK
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}
# Create new random API Key
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}