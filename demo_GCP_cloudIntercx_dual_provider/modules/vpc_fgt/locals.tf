locals {
  # ----------------------------------------------------------------------------------
  # Subnet cidrs (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  subnet_public_cidr  = cidrsubnet(var.vpc-sec_cidr, 2, 0)
  subnet_private_cidr = cidrsubnet(var.vpc-sec_cidr, 2, 1)
  subnet_mgmt_cidr    = cidrsubnet(var.vpc-sec_cidr, 2, 2)
  subnet_bastion_cidr = cidrsubnet(var.vpc-sec_cidr, 2, 3)
  # ----------------------------------------------------------------------------------
  # FGT IP (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  fgt-1_ni_mgmt_ip    = cidrhost(local.subnet_mgmt_cidr, var.cidr_host)
  fgt-1_ni_public_ip  = cidrhost(local.subnet_public_cidr, var.cidr_host)
  fgt-1_ni_private_ip = cidrhost(local.subnet_private_cidr, var.cidr_host)

  fgt-2_ni_mgmt_ip    = cidrhost(local.subnet_mgmt_cidr, var.cidr_host + 1)
  fgt-2_ni_public_ip  = cidrhost(local.subnet_public_cidr, var.cidr_host + 1)
  fgt-2_ni_private_ip = cidrhost(local.subnet_private_cidr, var.cidr_host + 1)
}