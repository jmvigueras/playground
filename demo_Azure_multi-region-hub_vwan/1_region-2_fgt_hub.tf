#------------------------------------------------------------------
# Create FGT HUB 
# - Config cluster FGSP
# - Create FGSP instances
# - Create vNet FGT
###################################################################
module "r2_fgt_hub_config" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs       = module.r2_fgt_hub_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r2_fgt_hub_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r2_fgt_hub_vnet.fgt-passive-ni_ips

  /* (uncommet to configure SDN connector instead of using instance metadata)
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  resource_group_name      = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  */

  config_fgcp  = local.r2_hub_cluster_type == "fgcp" ? true : false
  config_fgsp  = local.r2_hub_cluster_type == "fgsp" ? true : false
  config_hub   = true
  config_vxlan = true
  config_vhub  = true

  hub            = local.r2_hub
  hub_peer_vxlan = local.r2_hub_peer_vxlan
  vhub_peer      = azurerm_virtual_hub.r2_vhub.virtual_router_ips

  vpc-spoke_cidr = [local.r2_vhub_cidr, module.r2_fgt_hub_vnet.subnet_cidrs["bastion"]]
}
// Create FGT cluster as HUB-ADVPN
// (Example with a full scenario deployment with all modules)
module "r2_fgt_hub" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-r2-hub"
  location                 = local.region_2
  resource_group_name      = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r2_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fgt_size

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.r2_fgt_hub_vnet.fgt-active-ni_ids
  fgt-passive-ni_ids = module.r2_fgt_hub_vnet.fgt-passive-ni_ids
  fgt_config_1       = module.r2_fgt_hub_config.fgt_config_1
  fgt_config_2       = module.r2_fgt_hub_config.fgt_config_2

  fgt_passive = true
}
// Module VNET for FGT
// - This module will generate VNET and network intefaces for FGT cluster
module "r2_fgt_hub_vnet" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix              = "${local.prefix}-r2-hub"
  location            = local.region_2
  resource_group_name = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.r2_hub_vnet_cidr
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr

  accelerate = true
}

#------------------------------------------------------------------
# Create HUB LB in Region 12
#------------------------------------------------------------------
// Create load balancers
module "r2_xlb" {
  depends_on = [module.r2_fgt_hub_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/xlb"

  prefix              = "${local.prefix}-r2"
  location            = local.region_2
  resource_group_name = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  tags                = local.tags

  config_gwlb        = local.config_gwlb
  ilb_ip             = local.r2_ilb_ip
  backend-probe_port = local.backend-probe_port

  vnet-fgt           = module.r2_fgt_hub_vnet.vnet
  subnet_ids         = module.r2_fgt_hub_vnet.subnet_ids
  subnet_cidrs       = module.r2_fgt_hub_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r2_fgt_hub_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r2_fgt_hub_vnet.fgt-passive-ni_ips
}

#------------------------------------------------------------------
# Create vHUB
# - Create vNet spoke associated to vWAN
# - Create vHUB
# - Create vNet FGT association to vWAN
# - Create vHUB spoke Route Table
# - Create vNet spoke association to vWAN
#------------------------------------------------------------------
// Create vNet spoke
module "r2_hub_vnet_spoke" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-spoke"

  prefix              = "${local.prefix}-r2-vhub"
  location            = local.region_2
  resource_group_name = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  tags                = local.tags

  vnet-spoke_cidrs = local.r2_hub_vnet_spoke_cidrs
  vnet-fgt         = null
}
//Create Azure vHUB region 2
resource "azurerm_virtual_hub" "r2_vhub" {
  name                = "${local.prefix}-r2-vhub"
  resource_group_name = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  location            = local.region_2
  virtual_wan_id      = module.r1_vwan.vwan_id
  sku                 = "Standard"
  address_prefix      = local.r2_vhub_cidr

  tags = local.tags
}
//Create vHUB connection for FGT VNET
resource "azurerm_virtual_hub_connection" "r2_vhub_connnection_vnet_fgt" {
  name                      = "${local.prefix}-r2-cx-vnet-fgt"
  virtual_hub_id            = azurerm_virtual_hub.r2_vhub.id
  remote_virtual_network_id = module.r2_fgt_hub_vnet.vnet["id"]
}
//Create Azure vHUB spoke route table
resource "azurerm_virtual_hub_route_table" "r2_vhub_rt_spoke" {
  name           = "${local.prefix}-r2-vhub-rt-spoke"
  virtual_hub_id = azurerm_virtual_hub.r2_vhub.id
  labels         = ["rt-spoke"]

  route {
    name              = "rt-spoke-default"
    destinations_type = "CIDR"
    destinations      = ["0.0.0.0/0"]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_virtual_hub_connection.r2_vhub_connnection_vnet_fgt.id
  }
}
//Create connection of spoke VNETs to vHUB
resource "azurerm_virtual_hub_connection" "r2_vhub_connnection_vnet_spoke" {
  count                     = length(local.r2_hub_vnet_spoke_cidrs)
  name                      = "${local.prefix}-r2-cx-vnet-spoke"
  virtual_hub_id            = azurerm_virtual_hub.r2_vhub.id
  remote_virtual_network_id = module.r2_hub_vnet_spoke.vnet_ids[count.index]

  routing {
    associated_route_table_id = azurerm_virtual_hub_route_table.r2_vhub_rt_spoke.id
    propagated_route_table {
      route_table_ids = [azurerm_virtual_hub.r2_vhub.default_route_table_id]
    }
  }
}
//Create BGP connection to FGT VNET in vHUB
resource "azurerm_virtual_hub_bgp_connection" "r2_vhub_bgp_fgt-1" {
  depends_on                    = [azurerm_virtual_hub_connection.r2_vhub_connnection_vnet_fgt]
  name                          = "${local.prefix}-vhub-bgp-cx-fgt-active"
  virtual_hub_id                = azurerm_virtual_hub.r2_vhub.id
  peer_asn                      = local.r2_hub[0]["bgp_asn_hub"]
  peer_ip                       = module.r2_fgt_hub_vnet.fgt-active-ni_ips["private"]
  virtual_network_connection_id = azurerm_virtual_hub_connection.r2_vhub_connnection_vnet_fgt.id
}
resource "azurerm_virtual_hub_bgp_connection" "r2_vhub_bgp_fgt-2" {
  depends_on                    = [azurerm_virtual_hub_connection.r2_vhub_connnection_vnet_fgt]
  name                          = "${local.prefix}-vhub-bgp-cx-fgt-passive"
  virtual_hub_id                = azurerm_virtual_hub.r2_vhub.id
  peer_asn                      = local.r2_hub[0]["bgp_asn_hub"]
  peer_ip                       = module.r2_fgt_hub_vnet.fgt-passive-ni_ips["private"]
  virtual_network_connection_id = azurerm_virtual_hub_connection.r2_vhub_connnection_vnet_fgt.id
}

#------------------------------------------------------------------
# Create VM in vNet spoke
#------------------------------------------------------------------
module "r2_hub_vnet_spoke_vm" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh"

  prefix                   = "${local.prefix}-r1-spoke-vhub"
  location                 = local.region_2
  resource_group_name      = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r2_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  vm_ni_ids = [
    module.r2_hub_vnet_spoke.ni_ids["subnet1"][0],
  //  module.r2_hub_vnet_spoke.ni_ids["subnet2"][0]
  ]
}