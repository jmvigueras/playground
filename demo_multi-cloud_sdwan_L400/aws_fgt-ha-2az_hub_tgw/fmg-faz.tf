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

  nsg_ids = {
    public  = [module.fgt_hub_vpc.nsg_ids["allow_all"]]
    private = [module.fgt_hub_vpc.nsg_ids["bastion"]]
  }
  subnet_ids = {
    public  = module.fgt_hub_vpc.subnet_az1_ids["public"]
    private = module.fgt_hub_vpc.subnet_az1_ids["bastion"]
  }
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

  nsg_ids = {
    public  = [module.fgt_hub_vpc.nsg_ids["allow_all"]]
    private = [module.fgt_hub_vpc.nsg_ids["bastion"]]
  }
  subnet_ids = {
    public  = module.fgt_hub_vpc.subnet_az1_ids["public"]
    private = module.fgt_hub_vpc.subnet_az1_ids["bastion"]
  }
  subnet_cidrs = {
    public  = module.fgt_hub_vpc.subnet_az1_cidrs["public"]
    private = module.fgt_hub_vpc.subnet_az1_cidrs["bastion"]
  }
}