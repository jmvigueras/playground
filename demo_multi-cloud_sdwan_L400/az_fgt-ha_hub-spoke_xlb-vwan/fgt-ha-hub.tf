#------------------------------------------------------------------
# Create FGT HUB 
# - FGSP
# - vWAN association (dynamic routing to vHUB)
# - LB sandwich
# - Azure Route Server BGP session in vNet spoke FGT
# - vxlan interfaces to connecto to GWLB
###################################################################
module "fgt_hub_config" {
  depends_on = [module.xlb, module.fgt_hub_vnet, module.rs]
  source     = "git::github.com/jmvigueras/modules//azure/fgt-config"

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

  config_fgcp       = true
  config_hub        = true
  config_vhub       = true
  config_ars        = true
  config_vxlan      = true
  config_fmg        = true
  config_faz        = true

  hub               = local.hub
  hub-peer_vxlan    = local.hub_peer_vxlan

  vhub_peer         = module.vwan.virtual_router_ips
  rs_peer           = module.rs.rs_peer

  fmg_ip          = local.fmg_ip
  faz_ip          = local.faz_ip

  vpc-spoke_cidr = [module.fgt_hub_vnet.subnet_cidrs["bastion"], local.fgt_vnet-spoke_cidrs[0], local.vhub_vnet-spoke_cidrs[0]]
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

  vnet-fgt_cidr = local.hub["cidr"]
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr
}


###########################################################################
# Deploy complete architecture with other modules used as input in module
# - module vwan
# - module vnet-fgt
# - module vnet-spoke
# - module site-spoke-to-2hubs
# - module vwan
# - module xlb-fgt
# - module rs
############################################################################
// Module create vWAN and vHUB
module "vwan" {
  depends_on = [module.vnet-spoke-vhub, module.fgt_hub_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/vwan"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vhub_cidr              = local.vhub_cidr
  vnet_connection        = module.vnet-spoke-vhub.vnet_ids
  vnet-fgt_id            = module.fgt_hub_vnet.vnet["id"]
  fgt-cluster_active-ip  = module.fgt_hub_vnet.fgt-active-ni_ips["private"]
  fgt-cluster_passive-ip = module.fgt_hub_vnet.fgt-passive-ni_ips["private"]
  fgt-cluster_bgp-asn    = local.hub["bgp-asn_hub"]
}

// Module VNET spoke vHUB
// - This module will generate VNET spoke to connecto to vHUB 
module "vnet-spoke-vhub" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-spoke"

  prefix              = "${local.prefix}-vhub"
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vnet-spoke_cidrs = local.vhub_vnet-spoke_cidrs
  vnet-fgt         = null
}

// Module VNET spoke VNET FGT
// - This module will generate VNET spoke to connecto to VNET FGT
// - Module will peer VNET to VNET FGT
module "vnet-spoke-fgt" {
  depends_on = [module.fgt_hub_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/vnet-spoke"

  prefix              = "${local.prefix}-fgt"
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vnet-spoke_cidrs = local.fgt_vnet-spoke_cidrs
  vnet-fgt = {
    id   = module.fgt_hub_vnet.vnet["id"]
    name = module.fgt_hub_vnet.vnet["name"]
  }
}

// Create load balancers
module "xlb" {
  depends_on = [module.fgt_hub_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/xlb"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  config_gwlb        = local.config_gwlb
  ilb_ip             = local.ilb_ip
  backend-probe_port = local.backend-probe_port

  subnet_private = {
    cidr    = module.fgt_hub_vnet.subnet_cidrs["private"]
    id      = module.fgt_hub_vnet.subnet_ids["private"]
    vnet_id = module.fgt_hub_vnet.vnet["id"]
  }

  fgt-ni_ids = {
    fgt1_public  = module.fgt_hub_vnet.fgt-active-ni_ids["public"]
    fgt1_private = module.fgt_hub_vnet.fgt-active-ni_ids["private"]
    fgt2_public  = module.fgt_hub_vnet.fgt-passive-ni_ids["public"]
    fgt2_private = module.fgt_hub_vnet.fgt-passive-ni_ids["private"]
  }

  fgt-ni_ips = {
    fgt1_public  = module.fgt_hub_vnet.fgt-active-ni_ips["public"]
    fgt1_private = module.fgt_hub_vnet.fgt-active-ni_ips["private"]
    fgt2_public  = module.fgt_hub_vnet.fgt-passive-ni_ips["public"]
    fgt2_private = module.fgt_hub_vnet.fgt-passive-ni_ips["private"]
  }
}

// Create load balancers
module "rs" {
  depends_on = [module.vnet-spoke-fgt, module.fgt_hub_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/routeserver"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  subnet_ids   = module.vnet-spoke-fgt.subnet_ids["routeserver"]
  fgt_bgp-asn  = local.hub["bgp-asn_hub"]
  fgt1_peer-ip = module.fgt_hub_vnet.fgt-active-ni_ips["private"]
  fgt2_peer-ip = module.fgt_hub_vnet.fgt-passive-ni_ips["private"]
}

// Create virtual machines
module "vm_hub_vnet-spoke-fgt" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh"

  prefix                   = "${local.prefix}-spoke-fgt"
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = tls_private_key.ssh.public_key_openssh

  vm_ni_ids = [
    module.vnet-spoke-fgt.ni_ids["subnet1"][0],
    module.vnet-spoke-fgt.ni_ids["subnet2"][0]
  ]
}

module "vm_hub_vnet-spoke-vhub" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh"

  prefix                   = "${local.prefix}-spoke-vhub"
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = tls_private_key.ssh.public_key_openssh

  vm_ni_ids = [
    module.vnet-spoke-vhub.ni_ids["subnet1"][0],
    module.vnet-spoke-vhub.ni_ids["subnet2"][0]
  ]
}




