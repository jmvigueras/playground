#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#------------------------------------------------------------------------------------------------------------
module "fgt_ips-fwr" {
  source = "git::github.com/jmvigueras/modules//gcp/fgt-ha_ips-fwr"

  prefix = local.prefix

  admin_cidr   = local.admin_cidr
  subnet_cidrs = local.subnet_cidrs
  vpc_names    = local.vpc_names
}

#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#------------------------------------------------------------------------------------------------------------
module "fgt_config" {
  source = "git::github.com/jmvigueras/modules//gcp/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)

  subnet_cidrs       = local.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_ips-fwr.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_ips-fwr.fgt-passive-ni_ips

  config_fgcp = local.cluster_type == "fgcp" ? true : false
  config_fgsp = local.cluster_type == "fgsp" ? true : false

  cluster_pips     = ["${local.prefix}-active-public-ip"]
  route_tables     = concat(google_compute_route.private_route_to_fgt_default.*.name, google_compute_route.private_route_to_fgt_rfc1918.*.name)
  vpc-spoke_cidr   = concat(local.vpc-spoke_cidrs_1, local.vpc-spoke_cidrs_2)
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
  license_file_1 = local.license_file_1
  license_file_2 = local.license_file_2

  subnet_names          = local.subnet_names
  fgt-active-ni_ips     = module.fgt_ips-fwr.fgt-active-ni_ips
  fgt-passive-ni_ips    = module.fgt_ips-fwr.fgt-passive-ni_ips
 
  fgt_config_1 = module.fgt_config.fgt_config_1
  fgt_config_2 = module.fgt_config.fgt_config_2

  fgt_passive = local.fgt_passive
}









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