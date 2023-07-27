#------------------------------------------------------------------
# Create FGT Spoke OCI 
#------------------------------------------------------------------
// Create FGT config
module "fgt_config" {
  source           = "git::github.com/jmvigueras/modules//oci/fgt_config"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  license_type   = local.license_type

  fgt_subnet_cidrs = module.fgt_vcn.fgt_subnet_cidrs
  fgt_1_ips        = module.fgt_vcn.fgt_1_ips
  fgt_2_ips        = module.fgt_vcn.fgt_2_ips

  config_fgcp  = local.spoke_cluster_type == "fgcp" ? true : false
  config_fgsp  = local.spoke_cluster_type == "fgsp" ? true : false
  config_spoke = true
  spoke        = local.spoke
  hubs         = local.hubs

  vcn_spoke_cidrs = [module.fgt_vcn.fgt_subnet_cidrs["bastion"]]
}
// Create new Fortigate VNC
module "fgt_vcn" {
  source           = "git::github.com/jmvigueras/modules//oci/vcn_fgt"
  compartment_ocid = var.compartment_ocid

  region     = var.region
  prefix     = local.prefix
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port

  vcn_cidr = local.spoke["cidr"]
}
// Create FGT instances
module "fgt" {
  source           = "git::github.com/jmvigueras/modules//oci/fgt_ha"
  compartment_ocid = var.compartment_ocid

  region = var.region
  prefix = local.prefix

  license_type = local.license_type
  fgt_config_1 = module.fgt_config.fgt_config_1
  fgt_config_2 = module.fgt_config.fgt_config_2

  fgt_vcn_id     = module.fgt_vcn.fgt_vcn_id
  fgt_subnet_ids = module.fgt_vcn.fgt_subnet_ids
  fgt_nsg_ids    = module.fgt_vcn.fgt_nsg_ids
  fgt_1_ips      = module.fgt_vcn.fgt_1_ips
  fgt_2_ips      = module.fgt_vcn.fgt_2_ips
  fgt_1_vnic_ips = module.fgt_vcn.fgt_1_vnic_ips
  fgt_2_vnic_ips = module.fgt_vcn.fgt_2_vnic_ips
}
// Create new test instance
module "vm_bastion_oci" {
  source = "git::github.com/jmvigueras/modules//oci/instance"

  compartment_ocid = var.compartment_ocid
  prefix           = local.prefix

  subnet_id       = module.fgt_vcn.fgt_subnet_ids["bastion"]
  authorized_keys = local.authorized_keys
}

locals {
  authorized_keys = [chomp(tls_private_key.ssh.public_key_openssh)]
}



