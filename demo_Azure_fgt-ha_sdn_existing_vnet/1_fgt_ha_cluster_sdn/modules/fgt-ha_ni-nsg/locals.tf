locals {
  #------------------------------------------------------------------------------
  # IPs of network interfaces
  #------------------------------------------------------------------------------
  fgt-1_ni_mgmt_ip     = cidrhost(var.subnet_cidrs["mgmt"], 10)
  fgt-1_ni_public_ip_1 = cidrhost(var.subnet_cidrs["public"], 10)
  fgt-1_ni_public_ip_2 = cidrhost(var.subnet_cidrs["public"], 12)
  fgt-1_ni_private_ip  = cidrhost(var.subnet_cidrs["private"], 10)

  fgt-2_ni_mgmt_ip     = cidrhost(var.subnet_cidrs["mgmt"], 11)
  fgt-2_ni_public_ip_1 = cidrhost(var.subnet_cidrs["public"], 11)
  fgt-2_ni_public_ip_2 = cidrhost(var.subnet_cidrs["public"], 13)
  fgt-2_ni_private_ip  = cidrhost(var.subnet_cidrs["private"], 11)
}