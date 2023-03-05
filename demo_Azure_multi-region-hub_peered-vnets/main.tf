#---------------------------------------------------------------------------------------------------------
# Accept the Terms license for the FortiGate Marketplace image
# This is a one-time agreement that needs to be accepted per subscription
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/marketplace_agreement
#---------------------------------------------------------------------------------------------------------
/*
resource "azurerm_marketplace_agreement" "fortinet-payg" {
  publisher = "fortinet"
  offer     = "fortinet_fortigate-vm_v5"
  plan      = "fortinet_fg-vm_payg_2022"
}
resource "azurerm_marketplace_agreement" "fortinet-byol" {
  publisher = "fortinet"
  offer     = "fortinet_fortigate-vm_v5"
  plan      = "fortinet_fg-vm"
}
*/

#---------------------------------------------------------------------------------------------------------
# Necessary variables and data
#---------------------------------------------------------------------------------------------------------
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

resource "azurerm_storage_account" "r1_storageaccount" {
  count                    = local.storage-account_endpoint == null ? 1 : 0
  name                     = "r1stgra${random_id.randomId[count.index].hex}"
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  location                 = local.region_1
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  tags = local.tags
}

resource "azurerm_storage_account" "r2_storageaccount" {
  count                    = local.storage-account_endpoint == null ? 1 : 0
  name                     = "r2stgra${random_id.randomId[count.index].hex}"
  resource_group_name      = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  location                 = local.region_2
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  tags = local.tags
}

// Create Resource Group if it is null
resource "azurerm_resource_group" "r1_rg" {
  count    = local.r1_resource_group_name == null ? 1 : 0
  name     = "${local.prefix}-r1-rg"
  location = local.region_1

  tags = local.tags
}

// Create Resource Group if it is null
resource "azurerm_resource_group" "r2_rg" {
  count    = local.r2_resource_group_name == null ? 1 : 0
  name     = "${local.prefix}-r2-rg"
  location = local.region_2

  tags = local.tags
}