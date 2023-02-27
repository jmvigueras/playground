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

  vpc-sec_cidr = local.spoke["cidr"]
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#------------------------------------------------------------------------------------------------------------
module "fgt_config" {
  source = "git::github.com/jmvigueras/modules//gcp/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)

  subnet_cidrs       = module.fgt_vpc.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_vpc.fgt-passive-ni_ips

  config_fgcp  = true
  config_spoke = true
  config_ncc   = true
  config_fmg   = true
  config_faz   = true

  spoke        = local.spoke
  hubs         = local.hubs
  ncc_peers    = [module.fgt_vpc.ncc_private_ips]

  fmg_ip = local.fmg_ip
  faz_ip = local.faz_ip

  fmg_interface-select-method = "sdwan"
  faz_interface-select-method = "sdwan"
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

  fgt_passive = local.fgt_passive
}
#------------------------------------------------------------------------------------------------------------
# Create NCC Router Applicance (private)
#------------------------------------------------------------------------------------------------------------
module "ncc_private" {
  source = "git::github.com/jmvigueras/modules//gcp/ncc"

  prefix = local.prefix
  region = local.region

  vpc_name         = module.fgt_vpc.vpc_names["private"]
  subnet_self_link = module.fgt_vpc.subnet_self_links["private"]
  ncc_bgp-asn      = local.ncc_bgp-asn
  ncc_ips          = module.fgt_vpc.ncc_private_ips

  fgt_bgp-asn           = local.spoke["bgp-asn"]
  fgt-active-ni_ip      = module.fgt_vpc.fgt-active-ni_ips["private"]
  fgt-passive-ni_ip     = module.fgt_vpc.fgt-passive-ni_ips["private"]
  fgt_active_self_link  = module.fgt.fgt_active_self_link
  fgt_passive_self_link = module.fgt.fgt_passive_self_link[0]

  fgt_passive = local.fgt_passive
}
#------------------------------------------------------------------------------------------------------------
# Create VPC spokes peered to VPC FGT
#------------------------------------------------------------------------------------------------------------
module "vpc_spoke" {
  source = "git::github.com/jmvigueras/modules//gcp/vpc-spoke"

  prefix = local.prefix
  region = local.region

  spoke-subnet_cidrs = local.vpc_spoke-subnet_cidrs
  fgt_vpc_self_link  = module.fgt_vpc.vpc_self_links["private"]
}
#------------------------------------------------------------------------------------------------------------
# Create Internal and External Load Balancer
#------------------------------------------------------------------------------------------------------------
module "xlb" {
  source = "git::github.com/jmvigueras/modules//gcp/xlb"

  prefix = local.prefix
  region = local.region
  zone1  = local.zone1
  zone2  = local.zone1

  vpc_names             = module.fgt_vpc.vpc_names
  subnet_names          = module.fgt_vpc.subnet_names
  ilb_ip                = module.fgt_vpc.ilb_ip
  fgt_active_self_link  = module.fgt.fgt_active_self_link
  fgt_passive_self_link = module.fgt.fgt_passive_self_link[0]

  vpc_spoke_names = module.vpc_spoke.vpc_name
}
#------------------------------------------------------------------------------------------------------------
# Create vm instance in subnet bastion
#------------------------------------------------------------------------------------------------------------
module "fgt_vm_bastion" {
  source = "git::github.com/jmvigueras/modules//gcp/new-instance"

  prefix = local.prefix
  region = local.region
  zone   = local.zone1

  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = [module.fgt_vpc.subnet_names["bastion"]]
}
module "vm_spoke" {
  source = "git::github.com/jmvigueras/modules//gcp/new-instance"

  prefix = local.prefix
  region = local.region
  zone   = local.zone1

  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = module.vpc_spoke.subnet_name
}