#------------------------------------------------------------------
# Create FGT HUB 
# - Config cluster FGSP
# - Create FGSP instances
# - Create vNet FGT
#------------------------------------------------------------------
// Create cluster config
module "r1_fgt_hub_config" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs       = module.r1_fgt_hub_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r1_fgt_hub_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r1_fgt_hub_vnet.fgt-passive-ni_ips

  /* (uncommet to configure SDN connector instead of using instance metadata)
  subscription_id     = var.subscription_id
  client_id           = var.client_id
  client_secret       = var.client_secret
  tenant_id           = var.tenant_id
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  */

  config_fgcp  = local.r1_hub_cluster_type == "fgcp" ? true : false
  config_fgsp  = local.r1_hub_cluster_type == "fgsp" ? true : false
  config_hub   = true
  config_vxlan = true
  config_vhub  = true

  hub            = local.r1_hub
  hub_peer_vxlan = local.r1_hub_peer_vxlan
  vhub_peer      = module.r1_vwan.virtual_router_ips

  vpc-spoke_cidr = [local.r1_vhub_cidr, module.r1_fgt_hub_vnet.subnet_cidrs["bastion"]]
}
// Create FGT cluster as HUB-ADVPN
// (Example with a full scenario deployment with all modules)
module "r1_fgt_hub" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-r1-hub"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fgt_size

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.r1_fgt_hub_vnet.fgt-active-ni_ids
  fgt-passive-ni_ids = module.r1_fgt_hub_vnet.fgt-passive-ni_ids
  fgt_config_1       = module.r1_fgt_hub_config.fgt_config_1
  fgt_config_2       = module.r1_fgt_hub_config.fgt_config_2

  fgt_passive = true
}
// Module VNET for FGT
// - This module will generate VNET and network intefaces for FGT cluster
module "r1_fgt_hub_vnet" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix              = "${local.prefix}-r1-hub"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.r1_hub_vnet_cidr
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr

  accelerate = true
}

#------------------------------------------------------------------
# Create HUB LB in Region 1 
#------------------------------------------------------------------
module "r1_xlb" {
  depends_on = [module.r1_fgt_hub_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/xlb"

  prefix              = "${local.prefix}-r1"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  config_gwlb        = local.config_gwlb
  ilb_ip             = local.r1_ilb_ip
  backend-probe_port = local.backend-probe_port

  vnet-fgt           = module.r1_fgt_hub_vnet.vnet
  subnet_ids         = module.r1_fgt_hub_vnet.subnet_ids
  subnet_cidrs       = module.r1_fgt_hub_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r1_fgt_hub_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r1_fgt_hub_vnet.fgt-passive-ni_ips
}

#------------------------------------------------------------------
# Create vWAN 
# - Create vWAN and vHUB
# - Create vNet spoke associated to vWAN
# - Create VM in vNet spoke
#------------------------------------------------------------------
// Create vNet spoke
module "r1_hub_vnet_spoke" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-spoke"

  prefix              = "${local.prefix}-r1-vhub"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  vnet-spoke_cidrs = local.r1_hub_vnet_spoke_cidrs
  vnet-fgt         = null
}
// Create vWAN and vHUB
module "r1_vwan" {
  depends_on = [module.r1_hub_vnet_spoke, module.r1_fgt_hub_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/vwan"

  prefix              = "${local.prefix}-r1"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  vhub_cidr              = local.r1_vhub_cidr
  vnet_connection        = module.r1_hub_vnet_spoke.vnet_ids
  vnet-fgt_id            = module.r1_fgt_hub_vnet.vnet["id"]
  fgt-cluster_active-ip  = module.r1_fgt_hub_vnet.fgt-active-ni_ips["private"]
  fgt-cluster_passive-ip = module.r1_fgt_hub_vnet.fgt-passive-ni_ips["private"]
  fgt-cluster_bgp-asn    = local.r1_hub[0]["bgp_asn_hub"]
}
// Create VM in vNet spoke
module "r1_hub_vnet_spoke_vm" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh"

  prefix                   = "${local.prefix}-r1-spoke-vhub"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  vm_ni_ids = [
    module.r1_hub_vnet_spoke.ni_ids["subnet1"][0],
    // module.r1_hub_vnet_spoke.ni_ids["subnet2"][0]
  ]
}
