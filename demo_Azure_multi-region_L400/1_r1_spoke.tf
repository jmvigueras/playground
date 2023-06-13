#------------------------------------------------------------------
# Create FGT 
# - Module create cluster config
# - Module create instances
# - Module create VNet FGT
###################################################################
module "r1_spoke_config" {
  count  = local.r1_spoke_number
  source = "git::github.com/jmvigueras/modules//azure/fgt-config_v2"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs       = module.r1_spoke_vnet[count.index].subnet_cidrs
  fgt-active-ni_ips  = module.r1_spoke_vnet[count.index].fgt-active-ni_ips
  fgt-passive-ni_ips = module.r1_spoke_vnet[count.index].fgt-passive-ni_ips

  config_fgcp  = local.r1_spoke_cluster_type == "fgcp" ? true : false
  config_fgsp  = local.r1_spoke_cluster_type == "fgsp" ? true : false
  config_spoke = true

  spoke = {
    id      = "${local.r1_spoke["id"]}-${count.index + 1}"
    cidr    = cidrsubnet(local.r1_spoke["cidr"], ceil(log(local.r1_spoke_number, 2)), count.index)
    bgp_asn = local.r1_spoke["bgp_asn"]
  }
  hubs = local.hubs

  vpc-spoke_cidr = [module.r1_spoke_vnet[count.index].subnet_cidrs["bastion"], local.r1_hub_azure_sdwan_vnet_cidr, local.r1_hub_on_prem_vnet_cidr]
}
// Create FGT cluster as HUB-ADVPN
module "r1_fgt_spoke" {
  count  = local.r1_spoke_number
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-r1-spoke-${count.index + 1}"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fgt_size
  fgt_version              = local.fgt_version

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.r1_spoke_vnet[count.index].fgt-active-ni_ids
  fgt-passive-ni_ids = module.r1_spoke_vnet[count.index].fgt-passive-ni_ids
  fgt_config_1       = module.r1_spoke_config[count.index].fgt_config_1
  fgt_config_2       = module.r1_spoke_config[count.index].fgt_config_2

  fgt_passive = false
}
// Module VNET for FGT
module "r1_spoke_vnet" {
  count  = local.r1_spoke_number
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix              = "${local.prefix}-r1-spoke-${count.index + 1}"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = cidrsubnet(local.r1_spoke["cidr"], ceil(log(local.r1_spoke_number, 2)), count.index)

  admin_port = local.admin_port
  admin_cidr = local.admin_cidr

  accelerate = true
}

#--------------------------------------------------------------------------------
# Create spoke bastion VM
#--------------------------------------------------------------------------------
module "r1_spoke_vnet_vm" {
  count      = local.r1_spoke_number
  depends_on = [module.r1_spoke_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh_v2"

  prefix                   = "${local.prefix}-r1-vnet-spoke-${count.index + 1}"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_id   = module.r1_spoke_vnet[count.index].subnet_ids["bastion"]
  subnet_cidr = module.r1_spoke_vnet[count.index].subnet_cidrs["bastion"]
}
