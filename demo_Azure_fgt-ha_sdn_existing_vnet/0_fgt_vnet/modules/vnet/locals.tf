locals {
  # ----------------------------------------------------------------------------------
  # Subnet cidrs (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  subnet_mgmt_cidr        = cidrsubnet(var.vnet-fgt_cidr, 3, 1)
  subnet_public_cidr      = cidrsubnet(var.vnet-fgt_cidr, 3, 2)
  subnet_private_cidr     = cidrsubnet(var.vnet-fgt_cidr, 3, 3)
  subnet_protected_cidr     = cidrsubnet(var.vnet-fgt_cidr, 3, 4)
}