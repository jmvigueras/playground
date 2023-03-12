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
  */

  config_fgcp  = local.r2_hub_cluster_type == "fgcp" ? true : false
  config_fgsp  = local.r2_hub_cluster_type == "fgsp" ? true : false
  config_hub   = true
  config_vxlan = true

  hub            = local.r2_hub
  hub_peer_vxlan = local.r2_hub_peer_vxlan

  vpc-spoke_cidr = concat(local.r2_hub_vnet_spoke_cidrs, [module.r2_fgt_hub_vnet.subnet_cidrs["bastion"]])
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
# - Create Load Balancers
# - Create vNet spoke peered to vNET FGT
# - Create VM in vNet spoke
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
// Create vNet spoke
module "r2_hub_vnet_spoke" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-spoke"

  prefix              = "${local.prefix}-r2"
  location            = local.region_2
  resource_group_name = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  tags                = local.tags

  vnet-spoke_cidrs = local.r2_hub_vnet_spoke_cidrs
  vnet-fgt         = module.r2_fgt_hub_vnet.vnet
}
// Create VM in vNet spoke
module "r2_hub_vnet_spoke_vm" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh"

  prefix                   = "${local.prefix}-r2-hub-vnet-spoke"
  location                 = local.region_2
  resource_group_name      = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r2_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  vm_ni_ids = [
    module.r2_hub_vnet_spoke.ni_ids["subnet1"][0],
    //module.r2_hub_vnet_spoke.ni_ids["subnet2"][0]
  ]
}

#--------------------------------------------------------------------------------
# Create UDR in vNet spoke subnet 1 and 2 to iLB
#--------------------------------------------------------------------------------
// Route-table definition
resource "azurerm_route_table" "r2_hub_vnet_spoke_rt" {
  name                = "${local.prefix}-r2-hub-vnet-spoke-rt"
  location            = local.region_2
  resource_group_name = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name

  disable_bgp_route_propagation = false

  route {
    name                   = "rfc1918-1"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.r2_ilb_ip
  }
  route {
    name                   = "rfc1918-2"
    address_prefix         = "192.168.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.r2_ilb_ip
  }
  route {
    name                   = "rfc1918-3"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.r2_ilb_ip
  }
}
// Route table association
resource "azurerm_subnet_route_table_association" "r2_rta-spoke-subnet-1" {
  subnet_id      = module.r2_hub_vnet_spoke.subnet_ids["subnet_1"][0]
  route_table_id = azurerm_route_table.r2_hub_vnet_spoke_rt.id
}
// Route table association
resource "azurerm_subnet_route_table_association" "r2_rta-spoke-subnet-2" {
  subnet_id      = module.r2_hub_vnet_spoke.subnet_ids["subnet_2"][0]
  route_table_id = azurerm_route_table.r2_hub_vnet_spoke_rt.id
}