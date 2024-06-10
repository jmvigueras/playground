/*
# Create VNet
resource "azurerm_virtual_network" "vnet-fgt" {
  name                = "vnet-hub-hsjdbcn"
  address_space       = ["10.0.144.0/23"]
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name

  tags = local.tags
}
*/

# Create Foritgate VNet Subnets
module "fgt_vnet" {
  source = "./modules/vnet-fgt"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vnet_subnets = local.fgt_vnet_subnets
  vnet_name    = local.fgt_vnet["name"]

  admin_port = local.admin_port
  admin_cidr = local.admin_cidr
}
# Create Fortigates config
module "fgt_config" {
  source = "./modules/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  subnet_cidrs       = module.fgt_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_vnet.fgt-1-ni_ips
  fgt-passive-ni_ips = module.fgt_vnet.fgt-2-ni_ips

  config_fgcp = true
  config_xlb  = true
  elb_ip = ""
  ilb_ip = local.ilb_ip

}
# Create FGT cluster
module "fgt" {
  source = "./modules/fgt-ha"

  prefix                   = local.prefix
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.fgt_vnet.fgt-1-ni_ids
  fgt-passive-ni_ids = module.fgt_vnet.fgt-2-ni_ids
  fgt_config_1       = module.fgt_config.fgt_config_1
  fgt_config_2       = module.fgt_config.fgt_config_2

  fgt_passive  = true
  license_type = local.license_type
  fgt_version  = local.fgt_version
  size         = local.fgt_size
}
// Create load balancers (External and Internal)
module "xlb" {
  depends_on = [module.fgt_vnet]
  source     = "./modules/xlb"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags
  
  ilb_ip             = local.ilb_ip
  backend-probe_port = local.backend-probe_port

  vnet-fgt           = local.fgt_vnet
  subnet_ids         = module.fgt_vnet.subnet_ids
  subnet_cidrs       = module.fgt_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.fgt_vnet.fgt-1-ni_ips
  fgt-passive-ni_ips = module.fgt_vnet.fgt-2-ni_ips
}







#-----------------------------------------------------------------------
# Necessary variables
#-----------------------------------------------------------------------
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