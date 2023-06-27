#------------------------------------------------------------------
# Create FGT HUB 
# - Create FGT config
# - Create FGT
# - Create FGT VNet
# - Create LB
#------------------------------------------------------------------
// Create FGT config
module "fgt_config" {
  source = "./modules/fgt-config"

  admin_cidr     = local.admin_cidrs[0]
  admin_port     = local.admin_port
  rsa-public-key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  license_type   = local.license_type
  license_file_1 = local.fgt_1_license
  license_file_2 = local.fgt_2_license

  subnet_cidrs       = module.fgt_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_vnet.fgt-passive-ni_ips

  config_fgcp = local.fgt_cluster_mode == "fgcp" ? true : false
  config_fgsp = local.fgt_cluster_mode == "fgsp" ? true : false

  vpc-spoke_cidr = local.fgt_vnet_peer
}
// Create FGT instances
module "fgt" {
  source = "./modules/fgt-ha"

  prefix                   = local.prefix
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.fgt_vnet.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_vnet.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_config.fgt_config_1
  fgt_config_2       = module.fgt_config.fgt_config_2

  fgt_passive  = true
  license_type = local.license_type
  fgt_version  = local.fgt_version
  size         = local.fgt_size
}
// Module create VNet for FGT
module "fgt_vnet" {
  source = "./modules/vnet-fgt"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.fgt_vnet_cidr
  admin_port    = local.admin_port
  admin_cidrs   = local.admin_cidrs

  config_xlb = true
}
// Create load balancers
// - External Load Balancer
// - Internal Load Balancer
module "xlb" {
  depends_on = [module.fgt]
  source     = "./modules/xlb"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  config_gwlb        = false
  ilb_ip             = local.ilb_ip
  backend-probe_port = local.backend-probe_port

  vnet-fgt           = module.fgt_vnet.vnet
  subnet_ids         = module.fgt_vnet.subnet_ids
  subnet_cidrs       = module.fgt_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_vnet.fgt-passive-ni_ips
}
// Create load balancer
// - Internal LB in external subnet public-1
module "ilb_public_1" {
  depends_on = [module.fgt]
  source     = "./modules/ilb"

  prefix              = "${local.prefix}-public-1"
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  ilb_ip             = local.ilb_public_1
  backend-probe_port = local.backend-probe_port

  vnet-fgt          = module.fgt_vnet.vnet
  subnet_id         = module.fgt_vnet.subnet_ids["public_1"]
  subnet_cidr       = module.fgt_vnet.subnet_cidrs["public_1"]
  fgt-active-ni_ip  = module.fgt_vnet.fgt-active-ni_ips["public_1"]
  fgt-passive-ni_ip = module.fgt_vnet.fgt-passive-ni_ips["public_1"]
}
// Accept Azure marketplace agreement to deploy Fortigate image BYOL
/*
resource "azurerm_marketplace_agreement" "fgt_agreement" {  
  publisher = "fortinet"  
  offer     = "fortinet_fortigate-vm_v5"  
  plan      = "fortinet_fg-vm"
}
*/






#-----------------------------------------------------------------------
# Necessary variables
#-----------------------------------------------------------------------
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}
// Create storage account if not provided
resource "random_id" "randomId" {
  count       = local.storage-account_endpoint == null ? 1 : 0
  byte_length = 8
}
resource "azurerm_storage_account" "storageaccount" {
  count                    = local.storage-account_endpoint == null ? 1 : 0
  name                     = "stgra${random_id.randomId[count.index].hex}"
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  location                 = local.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"

  tags = local.tags
}
// Create Resource Group if it is null
resource "azurerm_resource_group" "rg" {
  count    = local.resource_group_name == null ? 1 : 0
  name     = "${local.prefix}-rg"
  location = local.location

  tags = local.tags
}