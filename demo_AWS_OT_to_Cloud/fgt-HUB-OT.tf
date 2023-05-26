#------------------------------------------------------------------------------
# Create HUB 1
# - VPC FGT hub-ot
# - config FGT hub-ot
# - FGT hub-ot
# - create TGW
# - Create VPC TGW spoke (associated to TGW spoke RT)
# - Create TGW connect (use GRE and dynamic routing to TGW)
# - Create test instances in VPC TGW spoke
#------------------------------------------------------------------------------
// Create VPC for HUB OT
module "fgt_hub_ot_vpc" {
  source = "git::github.com/jmvigueras/modules//aws/vpc-fgt-2az_tgw"

  prefix     = "${local.prefix}-hub-ot"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port
  region     = local.region

  vpc-sec_cidr          = local.hub_ot_fgt_vpc_cidr
  tgw_id                = module.tgw_hub_ot.tgw_id
  tgw_rt-association_id = module.tgw_hub_ot.rt_default_id
  tgw_rt-propagation_id = module.tgw_hub_ot.rt_vpc-spoke_id
}
// Create config for FGT HUB OT
module "fgt_hub_ot_config" {
  source = "git::github.com/jmvigueras/modules//aws/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_active_cidrs  = module.fgt_hub_ot_vpc.subnet_az1_cidrs
  subnet_passive_cidrs = module.fgt_hub_ot_vpc.subnet_az2_cidrs
  fgt-active-ni_ips    = module.fgt_hub_ot_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips   = module.fgt_hub_ot_vpc.fgt-passive-ni_ips

  config_fgcp    = local.hub_ot_cluster_type == "fgcp" ? true : false
  config_fgsp    = local.hub_ot_cluster_type == "fgsp" ? true : false
  config_hub     = true
  hub            = local.hub_ot
  vpc-spoke_cidr = [local.hub_ot_spoke_vpc_cidr, module.fgt_hub_ot_vpc.subnet_az1_cidrs["bastion"], module.fgt_hub_ot_vpc.subnet_az2_cidrs["bastion"]]
}
// Create FGT instances (Active-Active)
module "fgt_hub_ot" {
  source = "git::github.com/jmvigueras/modules//aws/fgt-ha"

  prefix        = "${local.prefix}-hub-ot"
  region        = local.region
  instance_type = local.instance_type
  keypair       = aws_key_pair.keypair.key_name

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt-active-ni_ids  = module.fgt_hub_ot_vpc.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_hub_ot_vpc.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_hub_ot_config.fgt_config_1
  fgt_config_2       = module.fgt_hub_ot_config.fgt_config_2

  fgt_ha_fgsp = local.hub_ot_cluster_type == "fgsp" ? true : false
  fgt_passive = true
}
// Create TGW
module "tgw_hub_ot" {
  source = "git::github.com/jmvigueras/modules//aws/tgw"

  prefix      = "${local.prefix}-ot"
  tgw_cidr    = local.tgw_it_cidr
  tgw_bgp-asn = local.tgw_it_bgp_asn
}
// Create VPC spoke attached to TGW
module "tgw_hub_ot_vpc-spoke" {
  count  = local.count_ot_spoke_vpcs
  source = "git::github.com/jmvigueras/modules//aws/vpc-spoke-2az-to-tgw"

  prefix     = "${local.prefix}-tgw-spoke-${count.index + 1}"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port
  region     = local.region

  vpc-spoke_cidr        = cidrsubnet(local.hub_ot_spoke_vpc_cidr, ceil(log(local.count_ot_spoke_vpcs, 2)), count.index)
  tgw_id                = module.tgw_hub_ot.tgw_id
  tgw_rt-association_id = module.tgw_hub_ot.rt_vpc-spoke_id
  tgw_rt-propagation_id = [module.tgw_hub_ot.rt_default_id, module.tgw_hub_ot.rt-vpc-sec-N-S_id, module.tgw_hub_ot.rt-vpc-sec-E-W_id]
}
// Create static route in TGW RouteTable Spoke
resource "aws_ec2_transit_gateway_route" "tgw_hub_ot_vpc-spoke_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.fgt_hub_ot_vpc.vpc_tgw-att_id
  transit_gateway_route_table_id = module.tgw_hub_ot.rt_vpc-spoke_id
}
// Create VM in spoke vpc to TGW AZ1
module "vm_tgw_hub_ot" {
  count  = local.count_ot_spoke_vpcs
  source = "git::github.com/jmvigueras/modules//aws/new-instance"

  prefix  = "${local.prefix}-tgw-hub-ot"
  keypair = aws_key_pair.keypair.key_name

  subnet_id       = module.tgw_hub_ot_vpc-spoke[count.index].subnet_az1_ids["vm"]
  security_groups = [module.tgw_hub_ot_vpc-spoke[count.index].nsg_ids["vm"]]
}
