locals {
  # VNet Id create from name
  vnet_id = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}"
  # VNet Subnet Ids from subnet name
  vnet_subnet_ids = {
    "public"  = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/asisa-subnet-public"
    "private" = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/asisa-subnet-private"
    "mgmt"    = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/asisa-subnet-hamgmt"
  }
}
# Create Foritgate VNet Subnets
module "fgt_nis" {
  source = "./modules/fgt-nis"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = local.tags

  subnet_cidrs = local.vnet_subnet_cidrs
  subnet_ids   = local.vnet_subnet_ids

  admin_port = local.admin_port
  admin_cidr = local.admin_cidr
}
# Create Fortigates config
module "fgt_config" {
  source = "./modules/fgt-config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = random_string.api_key.result

  subnet_cidrs       = local.vnet_subnet_cidrs
  fgt-active-ni_ips  = module.fgt_nis.fgt-1-ni_ips
  fgt-passive-ni_ips = module.fgt_nis.fgt-2-ni_ips

  config_fgcp = true
  config_xlb  = true
  elb_ip      = ""
  ilb_ip      = local.ilb_ip

}
# Create FGT cluster
module "fgt" {
  source = "./modules/fgt-ha"

  prefix                   = local.prefix
  location                 = local.location
  resource_group_name      = local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.fgt_nis.fgt-1-ni_ids
  fgt-passive-ni_ids = module.fgt_nis.fgt-2-ni_ids
  fgt_config_1       = module.fgt_config.fgt_config_1
  fgt_config_2       = module.fgt_config.fgt_config_2

  fgt_passive  = true
  license_type = local.license_type
  fgt_version  = local.fgt_version
  size         = local.fgt_size
}
// Create load balancers (External and Internal)
module "xlb" {
  depends_on = [module.fgt_nis]
  source     = "./modules/xlb"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = local.tags

  ilb_ip             = local.ilb_ip
  backend-probe_port = local.backend-probe_port
  elb_listeners      = local.elb_listeners

  vnet_id            = local.vnet_id
  subnet_ids         = local.vnet_subnet_ids
  subnet_cidrs       = local.vnet_subnet_cidrs
  fgt-active-ni_ips  = module.fgt_nis.fgt-1-ni_ips
  fgt-passive-ni_ips = module.fgt_nis.fgt-2-ni_ips
}




#-----------------------------------------------------------------------
# Necessary variables
#-----------------------------------------------------------------------
# Create private SSH keys
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

# Create storage account if not provided
resource "random_id" "randomId" {
  count       = local.storage-account_endpoint == null ? 1 : 0
  byte_length = 8
}
resource "azurerm_storage_account" "storageaccount" {
  count                    = local.storage-account_endpoint == null ? 1 : 0
  name                     = "stgra${random_id.randomId[count.index].hex}"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"

  tags = local.tags
}