#------------------------------------------------------------------------------------------------------------
# Create VPCs and subnets Fortigate
#
module "cloud_vpc" {
  source = "./modules/vpc_fgt"

  region = local.region
  prefix = "${local.prefix}-cloud"

  vpc-sec_cidr = local.cloud_vpc_cidr
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#
module "cloud_config" {
  source = "./modules/fgt_config_ha"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_cidrs       = module.cloud_vpc.subnet_cidrs
  fgt-active-ni_ips  = module.cloud_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips = module.cloud_vpc.fgt-passive-ni_ips

  fgt_active_extra-config = join("\n", [
    data.template_file.cloud_fw_policy.rendered,
    data.template_file.cloud_1_ilb-config.rendered,
    data.template_file.cloud_2_ilb-config.rendered
    ]
  )
  fgt_passive_extra-config = join("\n", [
    data.template_file.cloud_fw_policy.rendered,
    data.template_file.cloud_1_ilb-config.rendered,
    data.template_file.cloud_2_ilb-config.rendered
    ]
  )

  config_fgcp = local.cluster_type == "fgcp" ? true : false
  config_fgsp = local.cluster_type == "fgsp" ? true : false

  config_spoke = true
  hubs         = local.cloud_hubs
  spoke        = local.cloud_spoke

  vpc-spoke_cidr = local.cloud_peer_vpc_cidrs
}
# Extra config allow all firewall policy
data "template_file" "cloud_fw_policy" {
  template = templatefile("./templates/fgt_fw_policy.conf", {
    port = "port1"
  })
}
# Extra config allow secondary IP Fortigate1
data "template_file" "cloud_1_ilb-config" {
  template = templatefile("./templates/fgt_xlb-config.conf", {
    port   = "port2"
    ilb_ip = local.cloud_ilb_ip_1
  })
}
# Extra config allow secondary IP Fortigate2
data "template_file" "cloud_2_ilb-config" {
  template = templatefile("./templates/fgt_xlb-config.conf", {
    port   = "port2"
    ilb_ip = local.cloud_ilb_ip_2
  })
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster instances
#
module "cloud" {
  source  = "jmvigueras/ftnt-gcp-modules/gcp//modules/fgt_ha"
  version = "0.0.4"

  prefix = "${local.prefix}-cloud"
  region = local.region
  zone1  = local.zone1
  zone2  = local.zone2

  machine        = local.instance_type
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]
  license_type   = local.license_type
  fgt_version    = local.fgt_version

  subnet_names       = module.cloud_vpc.subnet_names
  fgt-active-ni_ips  = module.cloud_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips = module.cloud_vpc.fgt-passive-ni_ips

  fgt_config_1 = module.cloud_config.fgt_config_1
  fgt_config_2 = module.cloud_config.fgt_config_2

  config_fgsp = local.cluster_type == "fgsp" ? true : false

  fgt_passive = local.fgt_passive
}
#------------------------------------------------------------------------------------------------------------
# VPC spokes peered to VPC FGT and VMs
# - create VPC
# - create VMs
# - create tags routes
#------------------------------------------------------------------------------------------------------------
# Create VPCs
module "cloud_peer_vpc" {
  count  = length(local.cloud_peer_vpc_cidrs)
  source = "./modules/vpc_spoke"

  prefix = "${local.prefix}-spoke-${count.index + 1}"
  region = local.region

  spoke-subnet_cidr = local.cloud_peer_vpc_cidrs[count.index]
  fgt_vpc_self_link = module.cloud_vpc.vpc_self_links["private"]
}
# Create VMs
module "cloud_peer_vm" {
  count  = length(local.cloud_peer_vpc_cidrs)
  source = "./modules/vm"

  prefix = "${local.prefix}-peer-${count.index + 1}"
  region = local.region
  zone   = local.zone1

  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = module.cloud_peer_vpc[count.index].subnet_name
  tags        = ["zone1"]
}
# Create routes
resource "google_compute_route" "tag_route_to_spokes_zone1" {
  depends_on = [module.cloud_peer_vpc, module.ilb]
  count      = length(local.cloud_peer_vpc_cidrs)

  name         = "${local.prefix}-tag-route-peer-${count.index + 1}"
  dest_range   = "10.0.0.0/8"
  network      = module.cloud_peer_vpc[count.index].vpc_name
  next_hop_ilb = local.cloud_ilb_ip_1
  priority     = 100
  tags         = ["zone1"]
}
#------------------------------------------------------------------------------------------------------------
# Create Internal Load Balancers
#------------------------------------------------------------------------------------------------------------
module "ilb" {
  source = "./modules/ilb_v2"

  prefix = "${local.prefix}-cloud"
  region = local.region
  zone1  = local.zone1
  zone2  = local.zone2

  vpc_names             = module.cloud_vpc.vpc_names
  subnet_names          = module.cloud_vpc.subnet_names
  ilb_ip_private_1      = local.cloud_ilb_ip_1
  ilb_ip_private_2      = local.cloud_ilb_ip_2
  fgt_active_self_link  = module.cloud.fgt_active_self_link
  fgt_passive_self_link = module.cloud.fgt_passive_self_link[0]
}











