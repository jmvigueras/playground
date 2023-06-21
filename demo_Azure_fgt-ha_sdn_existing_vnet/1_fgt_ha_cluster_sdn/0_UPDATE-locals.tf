locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #----------------------------------------------------------------------------------------------------
  location                 = "francecentral"
  storage-account_endpoint = null           // a new resource group will be created if null
  prefix                   = "demo-sdn-evo" // prefix added to all resources created

  tags = {
    Deploy  = "module-fgt-ha-xlb"
    Project = "terraform-fortinet"
  }
  #-----------------------------------------------------------------------------------------------------
  # Existing resources (UPDATE)
  # - Resource group name
  # - FGT Vnet, subnets and cidrs
  #-----------------------------------------------------------------------------------------------------
  resource_group_name = "demo-sdn-evo-rg"

  fgt_vnet_name = "demo-sdn-evo-vnet-fgt"

  fgt_subnet_names = {
    "mgmt" = "demo-sdn-evo-subnet-hamgmt"
    "private" = "demo-sdn-evo-subnet-private"
    "protected" = "demo-sdn-evo-subnet-protected"
    "public" = "demo-sdn-evo-subnet-public"
  }

  fgt_subnet_cidrs = {
    "mgmt" = "172.30.0.64/26"
    "private" = "172.30.0.192/26"
    "protected" = "172.30.1.0/26"
    "public" = "172.30.0.128/26"
  }
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  admin_port = "8443"
  //admin_cidr     = "${chomp(data.http.my-public-ip.response_body)}/32"
  admin_cidr     = "0.0.0.0/0"
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  license_type   = "byol"
  license_file_1 = "./licenses/license1.lic"
  license_file_2 = "./licenses/license2.lic"

  fgt_size    = "Standard_F4s"
  fgt_version = "7.2.5"
  fgt_passive = true

  fgt_ports = {
    public  = "port1"
    private = "port2"
    mgtm    = "port3"
  }
}




#-----------------------------------------------------------------------
# Necessary resources (NO UPDATE)
#-----------------------------------------------------------------------
locals {
  // FGT subnets ids 
  fgt_subnet_ids = {
    protected = "${local.fgt_vnet["id"]}/subnets/${local.fgt_subnet_names["protected"]}"
    mgmt      = "${local.fgt_vnet["id"]}/subnets/${local.fgt_subnet_names["mgmt"]}"
    private   = "${local.fgt_vnet["id"]}/subnets/${local.fgt_subnet_names["private"]}"
    public    = "${local.fgt_vnet["id"]}/subnets/${local.fgt_subnet_names["public"]}"
  }
  fgt_vnet = {
    id   = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.fgt_vnet_name}"
    name = local.fgt_vnet_name
  }
}

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