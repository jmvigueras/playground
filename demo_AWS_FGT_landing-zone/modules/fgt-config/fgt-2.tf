##############################################################################################################
# FGT PASSIVE VM
##############################################################################################################

data "template_file" "fgt_passive" {
  template = file("${path.module}/templates/fgt-all.conf")

  vars = {
    fgt_id         = var.config_spoke ? "${var.spoke["id"]}-2" : "${var.hub["id"]}-2"
    admin_port     = var.admin_port
    admin_cidr     = var.admin_cidr
    adminusername  = "admin"
    type           = var.license_type
    license_file   = var.license_file_2
    rsa-public-key = var.rsa-public-key
    api_key        = var.api_key

    public_port  = var.public_port
    public_ip    = var.fgt-passive-ni_ips["public"]
    public_mask  = cidrnetmask(var.subnet_passive_cidrs["public"])
    public_gw    = cidrhost(var.subnet_passive_cidrs["public"], 1)
    private_port = var.private_port
    private_ip   = var.fgt-passive-ni_ips["private"]
    private_mask = cidrnetmask(var.subnet_passive_cidrs["private"])
    private_gw   = cidrhost(var.subnet_passive_cidrs["private"], 1)
    mgmt_port    = var.mgmt_port
    mgmt_ip      = var.fgt-passive-ni_ips["mgmt"]
    mgmt_mask    = cidrnetmask(var.subnet_passive_cidrs["mgmt"])
    mgmt_gw      = cidrhost(var.subnet_passive_cidrs["mgmt"], 1)

    fgt_sdn-config         = data.template_file.fgt_sdn-config.rendered
    fgt_ha-fgcp-config     = var.config_fgcp ? data.template_file.fgt_ha-fgcp-passive-config.rendered : ""
    fgt_ha-fgsp-config     = var.config_fgsp ? data.template_file.fgt_ha-fgsp-passive-config.rendered : ""
    fgt_bgp-config         = var.config_spoke ? data.template_file.fgt_spoke_bgp-config.rendered : var.config_hub ? data.template_file.fgt_hub_bgp-config.rendered : ""
    fgt_static-config      = var.vpc-spoke_cidr != null ? data.template_file.fgt_passive_static-config.rendered : ""
    fgt_sdwan-config       = var.config_spoke ? join("\n", data.template_file.fgt_sdwan-config.*.rendered) : ""
    fgt_tgw-gre-config     = var.config_tgw-gre ? data.template_file.fgt_passive_tgw-gre-config.rendered : ""
    fgt_vxlan-config       = var.config_vxlan ? data.template_file.fgt_vxlan-config.rendered : ""
    fgt_vpn-config         = var.config_hub ? var.config_fgsp ? data.template_file.fgt_vpn-config.1.rendered : data.template_file.fgt_vpn-config.0.rendered : ""
  //  fgt_gwlb-geneve-config = var.config_gwlb-geneve ? data.template_file.fgt_passive_gwlb-geneve-config.rendered : ""
    fgt_gwlb-geneve-config = ""
    fgt_fmg-config         = var.config_fmg ? data.template_file.fgt_2_fmg-config.rendered : ""
    fgt_faz-config         = var.config_faz ? data.template_file.fgt_2_faz-config.rendered : ""
    fgt_extra-config       = var.fgt_passive_extra-config
  }
}

data "template_file" "fgt_ha-fgcp-passive-config" {
  template = file("${path.module}/templates/fgt-ha-fgcp.conf")
  vars = {
    fgt_priority = 100
    ha_port      = var.mgmt_port
    ha_gw        = cidrhost(var.subnet_passive_cidrs["mgmt"], 1)
    peerip       = var.fgt-active-ni_ips["mgmt"]
  }
}

data "template_file" "fgt_ha-fgsp-passive-config" {
  template = file("${path.module}/templates/fgt-ha-fgsp.conf")
  vars = {
    mgmt_port     = var.mgmt_port
    mgmt_gw       = cidrhost(var.subnet_passive_cidrs["mgmt"], 1)
    peerip        = var.fgt-active-ni_ips["mgmt"]
    master_secret = random_string.fgsp_auto-config_secret.result
    master_ip     = var.fgt-active-ni_ips["mgmt"]
  }
}

data "template_file" "fgt_passive_static-config" {
  template = templatefile("${path.module}/templates/fgt-static.conf", {
    vpc-spoke_cidr = var.vpc-spoke_cidr
    port           = var.private_port
    gw             = cidrhost(var.subnet_passive_cidrs["private"], 1)
  })
}

data "template_file" "fgt_passive_tgw-gre-config" {
  template = file("${path.module}/templates/aws_fgt-tgw.conf")
  vars = {
    bgp-asn          = var.tgw_bgp-asn
    port             = var.private_port
    port_gw          = cidrhost(var.subnet_passive_cidrs["private"], 1)
    tunnel_local_ip  = var.fgt-passive-ni_ips["private"]
    remote_cidr      = var.tgw_cidr[0]
    tunnel_remote_ip = cidrhost(var.tgw_cidr[0], 11)
    local_ip         = cidrhost(var.tgw_inside_cidr[1], 1)
    remote_ip_1      = cidrhost(var.tgw_inside_cidr[1], 2)
    remote_ip_2      = cidrhost(var.tgw_inside_cidr[1], 3)
  }
}

/*
data "template_file" "fgt_passive_gwlb-geneve-config" {
  template = file("${path.module}/templates/aws_fgt-gwlb-geneve.conf")
  vars = {
    gwlbe_ip_az1    = var.gwlbe_ip[0]
    gwlbe_ip_az2    = var.gwlbe_ip[1]
    subnet-az1-gwlb = var.subnet_active_cidrs["gwlb"]
    subnet-az2-gwlb = var.subnet_passive_cidrs["gwlb"]
    private_port    = var.private_port
    private_gw      = cidrhost(var.subnet_passive_cidrs["private"], 1)
  }
}
*/

data "template_file" "fgt_2_faz-config" {
  template = file("${path.module}/templates/fgt-faz.conf")
  vars = {
    ip                      = var.faz_ip
    sn                      = var.faz_sn
    source-ip               = var.faz_fgt-2_source-ip
    interface-select-method = var.faz_interface-select-method
  }
}

data "template_file" "fgt_2_fmg-config" {
  template = file("${path.module}/templates/fgt-fmg.conf")
  vars = {
    ip                      = var.fmg_ip
    sn                      = var.fmg_sn
    source-ip               = var.fmg_fgt-2_source-ip
    interface-select-method = var.fmg_interface-select-method
  }
}