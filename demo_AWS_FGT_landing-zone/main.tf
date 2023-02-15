
// Create FGT instances
module "fgt" {
  source = "./modules/fgt-ha-2az"

  prefix        = local.prefix
  region        = local.region
  instance_type = local.instance_type
  keypair       = local.keypair_name == null ? aws_key_pair.keypair.key_name : local.keypair_name

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt-active-ni_ids  = module.fgt_ni-nsg.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_ni-nsg.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_config.fgt_config_1
  fgt_config_2       = module.fgt_config.fgt_config_2

  fgt_passive = true
}

// Create FGT cluster config
module "fgt_config" {
  source = "./modules/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = local.rsa-public-key == null ? trimspace(tls_private_key.ssh.public_key_openssh) : local.rsa-public-key
  api_key        = random_string.api_key.result

  subnet_active_cidrs  = module.fgt_vpc.subnet_az1_cidrs
  subnet_passive_cidrs = module.fgt_vpc.subnet_az2_cidrs
  fgt-active-ni_ips    = module.fgt_ni-nsg.fgt-active-ni_ips
  fgt-passive-ni_ips   = module.fgt_ni-nsg.fgt-passive-ni_ips

  config_fgcp    = true
  vpc-spoke_cidr = local.vpc-spoke_cidr
}

// Create FGT interfaces and SG
module "fgt_ni-nsg" {
  source = "./modules/fgt-ni-nsg"

  prefix     = "${local.prefix}-fgt-ni"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port

  subnet_az1_ids   = module.fgt_vpc.subnet_az1_ids
  subnet_az2_ids   = module.fgt_vpc.subnet_az2_ids
  subnet_az1_cidrs = module.fgt_vpc.subnet_az1_cidrs
  subnet_az2_cidrs = module.fgt_vpc.subnet_az2_cidrs

  vpc-sec_id = module.fgt_vpc.vpc-sec_id
}




#-----------------------------------------------------------------------------------------------------
# Used for simulated AWS VPC module
#-----------------------------------------------------------------------------------------------------
// Create VPC FGT
module "fgt_vpc" {
  source = "./modules/fgt-vpc"

  prefix = "${local.prefix}-fgt-vpc"
  region = local.region

  vpc-sec_cidr = "172.30.0.0/24"
}

