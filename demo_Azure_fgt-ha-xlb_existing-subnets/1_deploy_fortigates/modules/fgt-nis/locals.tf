locals {

  # ----------------------------------------------------------------------------------
  # FGT (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  fgt-1_ni_mgmt_ip    = cidrhost(var.subnet_cidrs["mgmt"], 10)
  fgt-1_ni_public_ip  = cidrhost(var.subnet_cidrs["public"], 10)
  fgt-1_ni_private_ip = cidrhost(var.subnet_cidrs["private"], 10)

  fgt-2_ni_mgmt_ip    = cidrhost(var.subnet_cidrs["mgmt"], 11)
  fgt-2_ni_public_ip  = cidrhost(var.subnet_cidrs["public"], 11)
  fgt-2_ni_private_ip = cidrhost(var.subnet_cidrs["private"], 11)

  fgt-1_ni_mgmt_name    = "${var.prefix}-ni-fgt-1-mgmt"
  fgt-1_ni_public_name  = "${var.prefix}-ni-fgt-1-public"
  fgt-1_ni_private_name = "${var.prefix}-ni-fgt-1-private"

  fgt-2_ni_mgmt_name    = "${var.prefix}-ni-fgt-2-mgmt"
  fgt-2_ni_public_name  = "${var.prefix}-ni-fgt-2-public"
  fgt-2_ni_private_name = "${var.prefix}-ni-fgt-2-private"
}