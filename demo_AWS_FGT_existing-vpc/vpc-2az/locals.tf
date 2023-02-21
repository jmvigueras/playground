locals {
  prefix = "demo-existing-vpc"
  region = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }
  vpc-sec_cidr = "172.30.0.0/23"
  
  # ----------------------------------------------------------------------------------
  # Subnet cidrs (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  subnet_az1_mgmt_cidr    = cidrsubnet(local.vpc-sec_cidr, 4, 0)
  subnet_az1_public_cidr  = cidrsubnet(local.vpc-sec_cidr, 4, 1)
  subnet_az1_private_cidr = cidrsubnet(local.vpc-sec_cidr, 4, 2)
  subnet_az1_tgw_cidr     = cidrsubnet(local.vpc-sec_cidr, 4, 3)
  subnet_az1_gwlb_cidr    = cidrsubnet(local.vpc-sec_cidr, 4, 4)
  subnet_az1_bastion_cidr = cidrsubnet(local.vpc-sec_cidr, 4, 5)

  subnet_az2_mgmt_cidr    = cidrsubnet(local.vpc-sec_cidr, 4, 8)
  subnet_az2_public_cidr  = cidrsubnet(local.vpc-sec_cidr, 4, 9)
  subnet_az2_private_cidr = cidrsubnet(local.vpc-sec_cidr, 4, 10)
  subnet_az2_tgw_cidr     = cidrsubnet(local.vpc-sec_cidr, 4, 11)
  subnet_az2_gwlb_cidr    = cidrsubnet(local.vpc-sec_cidr, 4, 12)
  subnet_az2_bastion_cidr = cidrsubnet(local.vpc-sec_cidr, 4, 13)

  # ----------------------------------------------------------------------------------
  # FGT IP (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  fgt-1_ni_mgmt_ip    = cidrhost(local.subnet_az1_mgmt_cidr, 10)
  fgt-1_ni_public_ip  = cidrhost(local.subnet_az1_public_cidr, 10)
  fgt-1_ni_private_ip = cidrhost(local.subnet_az1_private_cidr, 10)

  fgt-2_ni_mgmt_ip    = cidrhost(local.subnet_az2_mgmt_cidr, 11)
  fgt-2_ni_public_ip  = cidrhost(local.subnet_az2_public_cidr, 11)
  fgt-2_ni_private_ip = cidrhost(local.subnet_az2_private_cidr, 11)

  # ----------------------------------------------------------------------------------
  # FGT IPs (NOT UPDATE)
  # ----------------------------------------------------------------------------------
  fgt-1_ni_mgmt_ips    = [local.fgt-1_ni_mgmt_ip]
  fgt-1_ni_public_ips  = [local.fgt-1_ni_public_ip]
  fgt-1_ni_private_ips = [local.fgt-1_ni_private_ip]

  fgt-2_ni_mgmt_ips    = [local.fgt-2_ni_mgmt_ip]
  fgt-2_ni_public_ips  = [local.fgt-2_ni_public_ip]
  fgt-2_ni_private_ips = [local.fgt-2_ni_private_ip]
}