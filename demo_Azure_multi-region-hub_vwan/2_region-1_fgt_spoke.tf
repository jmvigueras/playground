#------------------------------------------------------------------
# Create FGT HUB 
# - Config cluster FGSP
# - Create FGSP instances
# - Create vNet FGT
###################################################################
module "r1_fgt_spoke_config" {
  count  = local.spoke_number
  source = "git::github.com/jmvigueras/modules//azure/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs       = module.r1_fgt_spoke_vnet[count.index].subnet_cidrs
  fgt-active-ni_ips  = module.r1_fgt_spoke_vnet[count.index].fgt-active-ni_ips
  fgt-passive-ni_ips = module.r1_fgt_spoke_vnet[count.index].fgt-passive-ni_ips

  /* (uncommet to configure SDN connector instead of using instance metadata)
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  */

  config_fgcp  = local.spoke_cluster_type == "fgcp" ? true : false
  config_fgsp  = local.spoke_cluster_type == "fgsp" ? true : false
  config_ars   = true
  config_spoke = true

  spoke = {
    id      = "${local.spoke["id"]}-${count.index + 1}"
    cidr    = cidrsubnet(local.spoke["cidr"], ceil(log(local.spoke_number, 2)), count.index)
    bgp_asn = local.r1_hub[0]["bgp_asn_spoke"]
  }
  hubs    = local.hubs
  rs_peer = module.r1_spoke_rs[count.index].rs_peer

  vpc-spoke_cidr = [module.r1_fgt_spoke_vnet[count.index].subnet_cidrs["bastion"]]
}
// Create FGT cluster as HUB-ADVPN
// (Example with a full scenario deployment with all modules)
module "r1_fgt_spoke" {
  count  = local.spoke_number
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-r1-spoke-${count.index + 1}"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fgt_size

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.r1_fgt_spoke_vnet[count.index].fgt-active-ni_ids
  fgt-passive-ni_ids = module.r1_fgt_spoke_vnet[count.index].fgt-passive-ni_ids
  fgt_config_1       = module.r1_fgt_spoke_config[count.index].fgt_config_1
  fgt_config_2       = module.r1_fgt_spoke_config[count.index].fgt_config_2

  fgt_passive = true
}
// Module VNET for FGT
// - This module will generate VNET and network intefaces for FGT cluster
module "r1_fgt_spoke_vnet" {
  count  = local.spoke_number
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix              = "${local.prefix}-r1-spoke-${count.index + 1}"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = cidrsubnet(local.spoke["cidr"], ceil(log(local.spoke_number, 2)), count.index)

  admin_port = local.admin_port
  admin_cidr = local.admin_cidr

  accelerate = true
}

#--------------------------------------------------------------------------------
# Create vNet FGT association to vHUB in region r1
#--------------------------------------------------------------------------------
//Create connection of spoke VNETs to vHUB
resource "azurerm_virtual_hub_connection" "r1_vhub_cx_vnet_fgt_spoke" {
  count                     = local.spoke_number
  name                      = "${local.prefix}-cx-vnet-fgt-spoke-${count.index + 1}"
  virtual_hub_id            = module.r1_vwan.virtual_hub_id
  remote_virtual_network_id = module.r1_fgt_spoke_vnet[count.index].vnet["id"]

  routing {
    associated_route_table_id = module.r1_vwan.vhub_rt_spoke_id  
    propagated_route_table {
      route_table_ids = [module.r1_vwan.vhub_rt_default_id]
    }
  }
}

#--------------------------------------------------------------------------------
# Create vNet spoke to FGT sdwan spoke
#--------------------------------------------------------------------------------
// Create vNet spoke to FGT vNet
module "r1_spoke_vnet" {
  count      = local.spoke_number
  depends_on = [module.r1_fgt_spoke_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/vnet-spoke"

  prefix              = "${local.prefix}-fgt-${count.index + 1}"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  vnet-spoke_cidrs = [cidrsubnet(local.r1_sdwan-spoke_cidrs, ceil(log(local.spoke_number, 2)), count.index)]
  vnet-fgt         = module.r1_fgt_spoke_vnet[count.index].vnet
}
// Create Azure Route Servers
module "r1_spoke_rs" {
  count      = local.spoke_number
  depends_on = [module.r1_fgt_spoke_vnet, module.r1_spoke_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/routeserver"

  prefix              = "${local.prefix}-${count.index + 1}"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  subnet_ids   = module.r1_spoke_vnet[count.index].subnet_ids["routeserver"]
  fgt_bgp-asn  = local.spoke["bgp_asn"]
  fgt1_peer-ip = module.r1_fgt_spoke_vnet[count.index].fgt-active-ni_ips["private"]
  fgt2_peer-ip = module.r1_fgt_spoke_vnet[count.index].fgt-passive-ni_ips["private"]
}
// Create VM spoke vNet
module "r1_spoke_vnet_vm" {
  count      = local.spoke_number
  depends_on = [module.r1_spoke_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh"

  prefix                   = "${local.prefix}-r1-spoke-${count.index + 1}"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  vm_ni_ids = [
    module.r1_spoke_vnet[count.index].ni_ids["subnet1"][0]
  ]
}