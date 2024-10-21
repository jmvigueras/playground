locals {
  # ----------------------------------------------------------------------------------
  # Subnet cidrs (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  subnet_mgmt_cidr        = cidrsubnet(var.vnet-fgt_cidr, 2, 0)
  subnet_public_cidr      = cidrsubnet(var.vnet-fgt_cidr, 2, 1)
  subnet_private_cidr     = cidrsubnet(var.vnet-fgt_cidr, 2, 2)
}