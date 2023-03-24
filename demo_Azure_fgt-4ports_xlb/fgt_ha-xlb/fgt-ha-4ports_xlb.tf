#------------------------------------------------------------------
# Create FGT HUB 
# - Create cluster FGCP config
# - Create FGCP instances
# - Create vNet
# - Create LB
#------------------------------------------------------------------
module "fgt_config" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-config_4ports"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs       = local.fgt_subnet_cidrs
  fgt-active-ni_ips  = module.fgt_ni-nsg.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_ni-nsg.fgt-passive-ni_ips

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  license_type   = local.license_type
  license_file_1 = local.license_file_1
  license_file_2 = local.license_file_2

  config_fgcp = true
}

// Create FGT cluster spoke
// (Example with a full scenario deployment with all modules)
module "fgt" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha_4ports"

  prefix                   = "${local.prefix}-spoke"
  location                 = local.location
  resource_group_name      = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.fgt_ni-nsg.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_ni-nsg.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_config.fgt_config_1
  fgt_config_2       = module.fgt_config.fgt_config_2

  fgt_passive  = true
  license_type = local.license_type
  fgt_version  = local.fgt_version
  size         = local.fgt_size

  fgt_ni_0 = "public"
  fgt_ni_1 = "private"
  fgt_ni_2 = "mgmt"
  fgt_ni_3 = "ha"
}

// Module generate NI and NSG 
// - This module will generate network intefaces and NSG for FGT cluster
module "fgt_ni-nsg" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha_4ports_ni-nsg"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
  tags                = local.tags

  admin_cidr   = local.admin_cidr
  admin_port   = local.admin_port
  subnet_ids   = local.fgt_subnet_ids
  subnet_cidrs = local.fgt_subnet_cidrs
}

// Create load balancers
module "xlb" {
  depends_on = [module.fgt_ni-nsg]
  source     = "git::github.com/jmvigueras/modules//azure/xlb"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
  tags                = local.tags

  config_gwlb        = local.config_gwlb
  ilb_ip             = local.ilb_ip
  backend-probe_port = local.backend-probe_port

  vnet-fgt           = local.fgt_vnet
  subnet_ids         = local.fgt_subnet_ids
  subnet_cidrs       = local.fgt_subnet_cidrs
  fgt-active-ni_ips  = module.fgt_ni-nsg.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_ni-nsg.fgt-passive-ni_ips
}


