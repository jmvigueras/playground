#------------------------------------------------------------------------------
# Create FAZ and FMG
#------------------------------------------------------------------------------
// Create FAZ
module "faz" {
  source = "git::github.com/jmvigueras/modules//aws/faz"

  prefix         = local.prefix
  region         = local.region
  keypair        = aws_key_pair.keypair.key_name
  rsa-public-key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  license_type = "byol"
  license_file = "./licenses/licenseFAZ.lic"

  faz_ni_ids = module.fgt_hub_vpc.faz_ni_ids
  faz_ni_ips = module.fgt_hub_vpc.faz_ni_ips
  subnet_cidrs = {
    public  = module.fgt_hub_vpc.subnet_az1_cidrs["public"]
    private = module.fgt_hub_vpc.subnet_az1_cidrs["bastion"]
  }
}
// Create FMG
module "fmg" {
  source = "git::github.com/jmvigueras/modules//aws/fmg"

  prefix         = local.prefix
  region         = local.region
  keypair        = aws_key_pair.keypair.key_name
  rsa-public-key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  license_type = "byol"
  license_file = "./licenses/licenseFMG.lic"

  fmg_ni_ids = module.fgt_hub_vpc.fmg_ni_ids
  fmg_ni_ips = module.fgt_hub_vpc.fmg_ni_ips
  subnet_cidrs = {
    public  = module.fgt_hub_vpc.subnet_az1_cidrs["public"]
    private = module.fgt_hub_vpc.subnet_az1_cidrs["bastion"]
  }
}