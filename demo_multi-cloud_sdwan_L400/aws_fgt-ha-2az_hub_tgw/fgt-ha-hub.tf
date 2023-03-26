#------------------------------------------------------------------------------
# Create HUB 1
# - vpc hub
# - config FGT hub (FGSP)
# - FGT hub
# - create TGW
# - Create VPC TGW spoke (associated to TGW spoke RT)
# - Create TGW connect (use GRE and dynamic routing to TGW)
#------------------------------------------------------------------------------
// Create VPC for HUB1
module "fgt_hub_vpc" {
  source = "git::github.com/jmvigueras/modules//aws/vpc-fgt-2az_tgw"

  prefix     = "${local.prefix}-hub"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port
  region     = local.region

  vpc-sec_cidr          = local.hub["cidr"]
  tgw_id                = module.tgw_hub.tgw_id
  tgw_rt-association_id = module.tgw_hub.rt_default_id
  tgw_rt-propagation_id = module.tgw_hub.rt_vpc-spoke_id
}
// Create config for FGT HUB1 (FGSP)
module "fgt_hub_config" {
  source = "git::github.com/jmvigueras/modules//aws/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_active_cidrs  = module.fgt_hub_vpc.subnet_az1_cidrs
  subnet_passive_cidrs = module.fgt_hub_vpc.subnet_az2_cidrs
  fgt-active-ni_ips    = module.fgt_hub_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips   = module.fgt_hub_vpc.fgt-passive-ni_ips

  config_fgsp     = true
  config_hub      = true
  config_tgw-gre  = true
  config_vxlan    = true
  config_fmg      = true
  config_faz      = true

  hub             = local.hub
  hub-peer_vxlan  = local.hub_peer_vxlan
  
  tgw_inside_cidr = local.tgw_inside_cidr
  tgw_cidr        = local.tgw_cidr
  tgw_bgp-asn     = local.tgw_bgp-asn
  
  fmg_ip          = module.fmg.ni_ips["private"]
  faz_ip          = module.faz.ni_ips["private"]

  vpc-spoke_cidr  = local.vpc-spoke_cidr
}
// Create FGT instances (Active-Active)
module "fgt_hub" {
  source = "git::github.com/jmvigueras/modules//aws/fgt-ha"

  prefix        = "${local.prefix}-hub"
  region        = local.region
  instance_type = local.instance_type
  keypair       = aws_key_pair.keypair.key_name

  license_type = local.fgt_license_type
  fgt_build    = local.fgt_build

  fgt-active-ni_ids  = module.fgt_hub_vpc.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_hub_vpc.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_hub_config.fgt_config_1
  fgt_config_2       = module.fgt_hub_config.fgt_config_2

  fgt_ha_fgsp = true
  fgt_passive = true
}
// Create TGW
module "tgw_hub" {
  source = "git::github.com/jmvigueras/modules//aws/tgw"

  prefix      = local.prefix
  tgw_cidr    = local.tgw_cidr
  tgw_bgp-asn = local.tgw_bgp-asn
}
// Create VPC spoke attached to TGW
module "tgw_hub_vpc-spoke" {
  count  = local.count
  source = "git::github.com/jmvigueras/modules//aws/vpc-spoke-2az-to-tgw"

  prefix     = "${local.prefix}-tgw-spoke-${count.index + 1}"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port
  region     = local.region

  vpc-spoke_cidr        = cidrsubnet(local.vpc-spoke_cidr[0], 1, count.index)
  tgw_id                = module.tgw_hub.tgw_id
  tgw_rt-association_id = module.tgw_hub.rt_vpc-spoke_id
  tgw_rt-propagation_id = [module.tgw_hub.rt_default_id, module.tgw_hub.rt-vpc-sec-N-S_id, module.tgw_hub.rt-vpc-sec-E-W_id]
}
// Create TGW connect
module "tgw_hub_connect" {
  source = "git::github.com/jmvigueras/modules//aws/tgw_connect"

  prefix         = local.prefix
  vpc_tgw-att_id = module.fgt_hub_vpc.vpc_tgw-att_id
  tgw_id         = module.tgw_hub.tgw_id
  peer_bgp-asn   = local.hub["bgp-asn_hub"]
  peer_ip = [
    module.fgt_hub_vpc.fgt-active-ni_ips["private"],
    module.fgt_hub_vpc.fgt-passive-ni_ips["private"]
  ]
  tgw_inside_cidr   = local.tgw_inside_cidr
  tgw_cidr          = local.tgw_cidr
  rt_propagation_id = [module.tgw_hub.rt_vpc-spoke_id]
}

#------------------------------------------------------------------------------
# - Create test instances in VPC TGW spoke (2 x Az1 and 2 x Az2)
#------------------------------------------------------------------------------
// Create VM in spoke vpc to TGW AZ1
module "vm_tgw_hub_az1" {
  count  = local.count
  source = "git::github.com/jmvigueras/modules//aws/new-instance"

  prefix  = "${local.prefix}-tgw-hub-az1"
  ni_id   = module.tgw_hub_vpc-spoke[count.index].az1-vm-ni_id
  keypair = aws_key_pair.keypair.key_name

  subnet_id       = module.tgw_hub_vpc-spoke[count.index].subnet_az1_ids["vm"]
  security_groups = [module.tgw_hub_vpc-spoke[count.index].nsg_ids["vm"]]
}
// Create VM in spoke vpc to TGW AZ2
module "vm_tgw_hub_az2" {
  count  = local.count
  source = "git::github.com/jmvigueras/modules//aws/new-instance"

  prefix  = "${local.prefix}-tgw-hub-az2"
  keypair = aws_key_pair.keypair.key_name

  subnet_id       = module.tgw_hub_vpc-spoke[count.index].subnet_az2_ids["vm"]
  security_groups = [module.tgw_hub_vpc-spoke[count.index].nsg_ids["vm"]]
}
