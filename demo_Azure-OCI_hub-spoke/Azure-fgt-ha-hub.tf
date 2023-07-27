#------------------------------------------------------------------
# Create FGT HUB 
# - FGSP
# - vWAN association (dynamic routing to vHUB)
# - LB sandwich
# - Azure Route Server BGP session in vNet spoke FGT
# - vxlan interfaces to connecto to GWLB
###################################################################
module "fgt_hub_config" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  subnet_cidrs       = module.fgt_hub_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_hub_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_hub_vnet.fgt-passive-ni_ips

  /*
  subscription_id      = var.subscription_id
  client_id            = var.client_id
  client_secret        = var.client_secret
  tenant_id            = var.tenant_id
  resource_group_name  = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  */

  config_fgcp = local.hub_cluster_type == "fgcp" ? true : false
  config_fgsp = local.hub_cluster_type == "fgsp" ? true : false
  config_hub  = true
  hub         = local.hub

  vpc-spoke_cidr = [module.fgt_hub_vnet.subnet_cidrs["bastion"]]
}
// Create FGT cluster as HUB-ADVPN
// (Example with a full scenario deployment with all modules)
module "fgt_hub" {
  depends_on = [module.fgt_hub_config]
  source     = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-hub"
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint

  admin_username = local.admin_username
  admin_password = local.admin_password
  fgt_version    = local.fgt_version

  fgt-active-ni_ids  = module.fgt_hub_vnet.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_hub_vnet.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_hub_config.fgt_config_1
  fgt_config_2       = module.fgt_hub_config.fgt_config_2

  fgt_passive = true
}
// Module VNET for FGT
// - This module will generate VNET and network intefaces for FGT cluster
module "fgt_hub_vnet" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt_v2"

  prefix              = "${local.prefix}-hub"
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.hub[0]["cidr"]
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr

  config_xlb = true // module variable to associate a public IP to fortigate's public interface (when using External LB, true means not to configure a public IP)
}
// Create load balancers
module "xlb" {
  source = "git::github.com/jmvigueras/modules//azure/xlb"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  config_gwlb        = local.config_gwlb
  backend-probe_port = local.backend-probe_port

  vnet-fgt           = module.fgt_hub_vnet.vnet
  subnet_ids         = module.fgt_hub_vnet.subnet_ids
  subnet_cidrs       = module.fgt_hub_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_hub_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_hub_vnet.fgt-passive-ni_ips
}
// Create virtual machines
module "vm_bastion_azure" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh_v2"

  prefix                   = "${local.prefix}-fgt-baston"
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_id   = module.fgt_hub_vnet.subnet_ids["bastion"]
  subnet_cidr = module.fgt_hub_vnet.subnet_cidrs["bastion"]
}


