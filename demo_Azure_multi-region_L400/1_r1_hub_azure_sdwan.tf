#------------------------------------------------------------------
# Create FGT HUB 
# - Config cluster FGSP
# - Create FGSP instances
# - Create vNet FGT
#------------------------------------------------------------------
// Create cluster config
module "r1_hub_azure_sdwan_config" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  /*
  # Config for SDN connector
  # - API calls
  subscription_id     = var.subscription_id
  client_id           = var.client_id
  client_secret       = var.client_secret
  tenant_id           = var.tenant_id
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  # - HA failover
  route_table          = "${local.prefix}-rt-default"
  cluster_pip          = module.r1_hub_azure_sdwan_vnet.fgt-active-public-name
  fgt-active-ni_names  = module.r1_hub_azure_sdwan_vnet.fgt-active-ni_names
  fgt-passive-ni_names = module.r1_hub_azure_sdwan_vnet.fgt-passive-ni_names
  # -
  */

  subnet_cidrs       = module.r1_hub_azure_sdwan_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r1_hub_azure_sdwan_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r1_hub_azure_sdwan_vnet.fgt-passive-ni_ips

  fgt_active_extra-config  = data.template_file.r1_hub_azure_sdwan_bgp-config.rendered
  fgt_passive_extra-config = data.template_file.r1_hub_azure_sdwan_bgp-config.rendered

  config_fgcp = local.r1_hub_azure_sdwan_type == "fgcp" ? true : false
  config_fgsp = local.r1_hub_azure_sdwan_type == "fgsp" ? true : false
  config_hub  = true

  hub = local.r1_hub_azure_sdwan

  vpc-spoke_cidr = [local.r1_hub_on_prem_vnet_cidr]
}
// FGT extra config (BGP to core)
data "template_file" "r1_hub_azure_sdwan_bgp-config" {
  template = templatefile("./templates/fgt_bgp-peers.conf", {
    peer_ips      = [local.r1_hub_azure_core_ilb_ip]
    peer_bgp_asn  = local.r1_hub_azure_core_bgp_asn
    route_map_out = ""
    port          = local.fgt_ports["private"]
    gw            = cidrhost(module.r1_hub_azure_sdwan_vnet.subnet_cidrs["private"], 1)
  })
}
// Create FGT cluster
module "r1_hub_azure_sdwan" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-r1-sdwan"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fgt_size
  fgt_version              = local.fgt_version

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.r1_hub_azure_sdwan_vnet.fgt-active-ni_ids
  fgt-passive-ni_ids = module.r1_hub_azure_sdwan_vnet.fgt-passive-ni_ids
  fgt_config_1       = module.r1_hub_azure_sdwan_config.fgt_config_1
  fgt_config_2       = module.r1_hub_azure_sdwan_config.fgt_config_2

  fgt_passive = false
}
// Module VNET for FGT
module "r1_hub_azure_sdwan_vnet" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix              = "${local.prefix}-r1-sdwan"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.r1_hub_azure_sdwan_vnet_cidr
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr

  accelerate = true
}

#--------------------------------------------------------------------------------
# Create UDR in VNet SDWAN to Azure Core
#--------------------------------------------------------------------------------
// Route-table definition
resource "azurerm_route_table" "r1_hub_azure_sdwan_vnet_rt" {
  name                = "${local.prefix}-r1_hub_azure_sdwan_vnet_rt"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name

  disable_bgp_route_propagation = false

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.r1_hub_azure_core_ilb_ip
  }
}
// Route table association
resource "azurerm_subnet_route_table_association" "r1_hub_azure_sdwan_vnet_rta_private" {
  subnet_id      = module.r1_hub_azure_sdwan_vnet.subnet_ids["private"]
  route_table_id = azurerm_route_table.r1_hub_azure_sdwan_vnet_rt.id
}
