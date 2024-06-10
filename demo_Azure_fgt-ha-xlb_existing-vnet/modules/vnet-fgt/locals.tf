locals {
  # ----------------------------------------------------------------------------------
  # Subnet cidrs (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  subnet_mgmt_cidr    = lookup(var.vnet_subnets, "mgmt", cidrsubnet(var.default_vnet_cidr, 2, 0))
  subnet_public_cidr  = lookup(var.vnet_subnets, "public", cidrsubnet(var.default_vnet_cidr, 2, 1))
  subnet_private_cidr = lookup(var.vnet_subnets, "private", cidrsubnet(var.default_vnet_cidr, 2, 2))

  # ----------------------------------------------------------------------------------
  # FGT (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  fgt-1_ni_mgmt_ip    = cidrhost(local.subnet_mgmt_cidr, 10)
  fgt-1_ni_public_ip  = cidrhost(local.subnet_public_cidr, 10)
  fgt-1_ni_private_ip = cidrhost(local.subnet_private_cidr, 10)

  fgt-2_ni_mgmt_ip    = cidrhost(local.subnet_mgmt_cidr, 11)
  fgt-2_ni_public_ip  = cidrhost(local.subnet_public_cidr, 11)
  fgt-2_ni_private_ip = cidrhost(local.subnet_private_cidr, 11)

  fgt-1_ni_mgmt_name    = "${var.prefix}-ni-fgt-1-mgmt"
  fgt-1_ni_public_name  = "${var.prefix}-ni-fgt-1-public"
  fgt-1_ni_private_name = "${var.prefix}-ni-fgt-1-private"

  fgt-2_ni_mgmt_name    = "${var.prefix}-ni-fgt-2-mgmt"
  fgt-2_ni_public_name  = "${var.prefix}-ni-fgt-2-public"
  fgt-2_ni_private_name = "${var.prefix}-ni-fgt-2-private"
}