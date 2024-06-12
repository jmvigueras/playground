#------------------------------------------------------------------------------------------------------------
# Create Network Connectivity Center
#------------------------------------------------------------------------------------------------------------
resource "google_network_connectivity_hub" "ncc_hub" {
  name = "${"${local.prefix}-cloud-vpn1"}-ncc"
  labels = {
    label-one = "${"${local.prefix}-cloud-vpn1"}"
  }
}

#------------------------------------------------------------------------------------------------------------
# FGT Cloud
#------------------------------------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------------------------------------
module "cloud_vpn1_vpc" {
  source = "./modules/vpc_fgt"

  region = local.region
  prefix = "${local.prefix}-cloud-vpn1"

  vpc-sec_cidr = local.cloud_vpn1_vpc_cidr
}
# Create FGT VPN1 Config
#
module "cloud_vpn1_config" {
  source = "./modules/fgt_config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)
  license_type   = local.license_type

  subnet_cidrs = module.cloud_vpn1_vpc.subnet_cidrs
  fgt_ni_ips   = local.cloud_vpn1_ips

  fgt_extra-config = join("\n", [
    data.template_file.cloud_vpn1_bgp_networks.rendered,
    data.template_file.cloud_vpn1_fw_policy.rendered
    ]
  )

  config_ncc  = true
  ncc_peers   = [local.cloud_cloud_router_ips]
  ncc_bgp-asn = local.cloud_cloud_router_bgp_asn

  config_s2s = true
  s2s_peers  = local.cloud_s2s

  bgp_asn_default = local.cloud_vpn1_bgp_asn

  vpc-spoke_cidr = [
    local.cloud_vpc_cidr,
    "${local.cloud_ilb_ip_1}/32",
    "${local.cloud_ilb_ip_2}/32"
  ]
}
# Add BGP networks
data "template_file" "cloud_vpn1_bgp_networks" {
  template = templatefile("${path.module}/templates/fgt_bgp_network.conf", {
    bgp_networks = [
      "${module.onprem_vpc.fgt-active-ni_ips["private"]}/32",  // FGT onprem primary IP
      "${module.onprem_vpc.fgt-passive-ni_ips["private"]}/32}" // FGT onprem secondary IP
    ]
  })
}
# Add default firewall policy
data "template_file" "cloud_vpn1_fw_policy" {
  template = templatefile("./templates/fgt_fw_policy.conf", {
    port = "port1"
  })
}
#------------------------------------------------------------------------------------------------------------
# Create FGT VPN1 instance
#
module "cloud_vpn1" {
  source = "./modules/fgt"

  region = local.region
  prefix = "${local.prefix}-cloud-vpn1"
  zone1  = local.zone1

  machine        = local.instance_type
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]
  license_type   = local.license_type
  fgt_version    = local.fgt_version

  subnet_names = module.cloud_vpn1_vpc.subnet_names
  fgt-ni_ips   = local.cloud_vpn1_ips

  fgt_config = module.cloud_vpn1_config.fgt_config
}
#------------------------------------------------------------------------------------------------------------
# Create NCC Router Applicance
#
module "cloud_vpn1_ncc_router_appliance" {
  source = "./modules/ncc_router_appliance"

  prefix = "${local.prefix}-cloud-vpn1"
  region = local.region

  ncc_hub_id = google_network_connectivity_hub.ncc_hub.id
  vpc_name   = module.cloud_vpn1_vpc.vpc_names["private"]

  fgt_ip        = local.cloud_vpn1_ips["private"]
  fgt_self_link = module.cloud_vpn1.fgt_self_link
}
#------------------------------------------------------------------------------------------------------------
# Create Cloud Router
#
module "cloud_vpn1_cloud_router" {
  depends_on = [module.cloud_vpn1_ncc_router_appliance]
  source     = "./modules/cloud_router"

  prefix = "${local.prefix}-cloud-vpn1"
  region = local.region

  vpc_name         = module.cloud_vpn1_vpc.vpc_names["private"]
  subnet_self_link = module.cloud_vpn1_vpc.subnet_self_links["private"]

  bgp_asn          = local.cloud_cloud_router_bgp_asn
  cloud_router_ips = local.cloud_cloud_router_ips

  fgt_bgp_asn   = local.cloud_vpn1_bgp_asn
  fgt_ip        = local.cloud_vpn1_ips["private"]
  fgt_self_link = module.cloud_vpn1.fgt_self_link
}
#------------------------------------------------------------------------------------------------------------
# Create VPC peerings - VPC Cloud VPN to VCP FGT
#
# Private to private VPC peerings
resource "google_compute_network_peering" "vpc_vpn1_peer_fgt_vpc_private_1" {
  name                 = "${local.prefix}-peer-vpn1-to-private-1"
  network              = module.cloud_vpn1_vpc.vpc_self_links["private"]
  peer_network         = module.cloud_vpc.vpc_self_links["private"]
  export_custom_routes = true
}
resource "google_compute_network_peering" "vpc_vpn1_peer_fgt_vpc_private_2" {
  name                 = "${local.prefix}-peer-vpn1-to-private-2"
  network              = module.cloud_vpc.vpc_self_links["private"]
  peer_network         = module.cloud_vpn1_vpc.vpc_self_links["private"]
  import_custom_routes = true
}