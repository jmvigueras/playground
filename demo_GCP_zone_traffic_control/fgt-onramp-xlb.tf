#------------------------------------------------------------------------------------------------------------
# Create VPCs and subnets Fortigate
# - VPC for MGMT and HA interface
# - VPC for Public interface
# - VPC for Private interface  
#------------------------------------------------------------------------------------------------------------
module "fgt_vpc" {
  source = "git::github.com/jmvigueras/modules//gcp/vpc-fgt"

  region = local.region
  prefix = local.prefix

  vpc-sec_cidr = local.onramp["cidr"]
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#------------------------------------------------------------------------------------------------------------
module "fgt_config" {
  source = "./modules/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)

  subnet_cidrs       = module.fgt_vpc.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_vpc.fgt-passive-ni_ips

  fgt_active_extra-config  = join("\n", [data.template_file.fgt_extra-config.rendered, data.template_file.fgt_1_ilb-config.rendered])
  fgt_passive_extra-config = join("\n", [data.template_file.fgt_extra-config.rendered, data.template_file.fgt_2_ilb-config.rendered])

  config_fgcp  = local.cluster_type == "fgcp" ? true : false
  config_fgsp  = local.cluster_type == "fgsp" ? true : false

  vpc-spoke_cidr = concat(local.vpc_spoke-subnet_cidrs, [module.fgt_vpc.subnet_cidrs["bastion"]])
}
# Extra config allow traffic create dynamic object subnet spokes and firewall policy
data "template_file" "fgt_extra-config" {
  template = templatefile("./templates/fgt_extra-config.conf", {
    prefix  = local.prefix
    subnets = [for vpc in module.vpc_spoke : vpc.subnet_name ]
  })
}
# Extra config allow secondary IP Fortigate1
data "template_file" "fgt_1_ilb-config" {
  template = templatefile("./templates/fgt_xlb-config.conf", {
    port   = "port2"
    ilb_ip = local.ilb_ip_private_zone1
  })
}
# Extra config allow secondary IP Fortigate2
data "template_file" "fgt_2_ilb-config" {
  template = templatefile("./templates/fgt_xlb-config.conf", {
    port   = "port2"
    ilb_ip = local.ilb_ip_private_zone2
  })
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster instances
#------------------------------------------------------------------------------------------------------------
module "fgt" {
  source = "git::github.com/jmvigueras/modules//gcp/fgt-ha"

  prefix = local.prefix
  region = local.region
  zone1  = local.zone1
  zone2  = local.zone2

  machine        = local.machine
  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]
  license_type   = local.license_type

  subnet_names       = module.fgt_vpc.subnet_names
  fgt-active-ni_ips  = module.fgt_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_vpc.fgt-passive-ni_ips

  fgt_config_1 = module.fgt_config.fgt_config_1
  fgt_config_2 = module.fgt_config.fgt_config_2

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
module "vpc_spoke" {
  count  = length(local.vpc_spoke-subnet_cidrs)
  source = "./modules/vpc-spoke"

  prefix = "${local.prefix}-spoke-${count.index + 1}"
  region = local.region

  spoke-subnet_cidr  = local.vpc_spoke-subnet_cidrs[count.index]
  fgt_vpc_self_link  = module.fgt_vpc.vpc_self_links["private"]
}
# Create VMs
module "vm_spoke_zone1" {
  count  = length(local.vpc_spoke-subnet_cidrs)
  source = "./modules/new-instance"

  prefix = "${local.prefix}-zone1-spoke-${count.index + 1}"
  region = local.region
  zone   = local.zone1

  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = module.vpc_spoke[count.index].subnet_name
  tags        = ["zone1"]
}
module "vm_spoke_zone2" {
  count  = length(local.vpc_spoke-subnet_cidrs)
  source = "./modules/new-instance"

  prefix = "${local.prefix}-zone2-spoke-${count.index + 1}"
  region = local.region
  zone   = local.zone2

  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = module.vpc_spoke[count.index].subnet_name
  tags        = ["zone2"]
}
# Create routes
resource "google_compute_route" "tag_route_to_spokes_zone1" {
  depends_on   = [module.vpc_spoke, module.ilb]
  count        = length(local.vpc_spoke-subnet_cidrs)
  name         = "${local.prefix}-tag-route-spoke-${count.index + 1}-zone1"
  dest_range   = "172.16.0.0/12"
  network      = module.vpc_spoke[count.index].vpc_name
  next_hop_ilb = local.ilb_ip_private_zone1
  priority     = 100
  tags         = ["zone1"]
}
resource "google_compute_route" "tag_route_to_spokes_zone2" {
  depends_on   = [module.vpc_spoke, module.ilb]
  count        = length(local.vpc_spoke-subnet_cidrs)
  name         = "${local.prefix}-tag-route-spoke-${count.index + 1}-zone2"
  dest_range   = "172.16.0.0/12"
  network      = module.vpc_spoke[count.index].vpc_name
  next_hop_ilb = local.ilb_ip_private_zone2
  priority     = 100
  tags         = ["zone2"]
}
#------------------------------------------------------------------------------------------------------------
# Create Internal and External Load Balancer
#------------------------------------------------------------------------------------------------------------
module "ilb" {
  source = "./modules/ilb"

  prefix = local.prefix
  region = local.region
  zone1  = local.zone1
  zone2  = local.zone2

  vpc_names             = module.fgt_vpc.vpc_names
  subnet_names          = module.fgt_vpc.subnet_names
  ilb_ip_private_1      = local.ilb_ip_private_zone1
  ilb_ip_private_2      = local.ilb_ip_private_zone2
  fgt_active_self_link  = module.fgt.fgt_active_self_link
  fgt_passive_self_link = module.fgt.fgt_passive_self_link[0]
}
/*
#------------------------------------------------------------------------------------------------------------
# Create NCC Router Applicance (private)
#------------------------------------------------------------------------------------------------------------
module "ncc_public" {
  source = "git::github.com/jmvigueras/modules//gcp/ncc"

  prefix = local.prefix
  region = local.region

  vpc_name         = module.fgt_vpc.vpc_names["public"]
  subnet_self_link = module.fgt_vpc.subnet_self_links["public"]
  ncc_bgp-asn      = local.ncc_bgp_asn
  ncc_ips          = module.fgt_vpc.ncc_public_ips

  fgt_bgp-asn           = local.onramp["bgp_asn"]
  fgt-active-ni_ip      = module.fgt_vpc.fgt-active-ni_ips["public"]
  fgt-passive-ni_ip     = module.fgt_vpc.fgt-passive-ni_ips["public"]
  fgt_active_self_link  = module.fgt.fgt_active_self_link
  fgt_passive_self_link = module.fgt.fgt_passive_self_link[0]

  fgt_passive = local.fgt_passive
}
*/





#------------------------------------------------------------------------------------------------------------
# Necessary variables
#------------------------------------------------------------------------------------------------------------
// GET deploy public IP for management
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}

data "google_client_openid_userinfo" "me" {}

resource "tls_private_key" "ssh-rsa" {
  algorithm = "RSA"
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh-rsa.private_key_pem
  filename        = ".ssh/ssh-key.pem"
  file_permission = "0600"
}