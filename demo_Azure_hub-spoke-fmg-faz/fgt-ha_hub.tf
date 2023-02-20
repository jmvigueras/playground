#------------------------------------------------------------------
# Create FGT HUB 
# - Config cluster FGSP
# - Create FGSP instances
# - Create vNet FGT
###################################################################
module "fgt_hub_config" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs       = module.fgt_hub_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_hub_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_hub_vnet.fgt-passive-ni_ips

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  config_fgsp = true
  config_hub  = true
  config_fmg  = true
  config_faz  = true
  hub         = local.hub1
  fmg_ip      = module.fgt_hub_vnet.fmg_ni_ips["private"]
  faz_ip      = module.fgt_hub_vnet.faz_ni_ips["private"]

  fmg_fgt-1_source-ip = module.fgt_hub_vnet.fgt-active-ni_ips["private"]
  fmg_fgt-2_source-ip = module.fgt_hub_vnet.fgt-passive-ni_ips["private"]
  faz_fgt-1_source-ip = module.fgt_hub_vnet.fgt-active-ni_ips["private"]
  faz_fgt-2_source-ip = module.fgt_hub_vnet.fgt-passive-ni_ips["private"]

  vpc-spoke_cidr = [module.fgt_hub_vnet.subnet_cidrs["bastion"]]
}

// Create FGT cluster as HUB-ADVPN
// (Example with a full scenario deployment with all modules)
module "fgt_hub" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-hub"
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fgt_size

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.fgt_hub_vnet.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_hub_vnet.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_hub_config.fgt_config_1
  fgt_config_2       = module.fgt_hub_config.fgt_config_2

  fgt_passive = true
}

// Module VNET for FGT
// - This module will generate VNET and network intefaces for FGT cluster
module "fgt_hub_vnet" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix              = "${local.prefix}-hub"
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.hub1["cidr"]
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr

  accelerate = true
}
