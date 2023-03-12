#-----------------------------------------------------------------------
# UPDATE LOCALS
#-----------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  location                 = "francecentral"
  storage-account_endpoint = null                 // a new resource group will be created if null
  prefix                   = "demo-fgt-ha-4ports" // prefix added to all resources created

  tags = {
    Deploy  = "module-fgt-ha-xlb"
    Project = "terraform-fortinet"
  }
  #-----------------------------------------------------------------------------------------------------
  # FGT variables 
  #-----------------------------------------------------------------------------------------------------
  admin_port     = "8443"
  admin_cidr     = "0.0.0.0/0"
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  fgt_size    = "Standard_F4"
  fgt_version = "6.4.11"

  license_type   = "byol"
  license_file_1 = "./licenses/license1.lic"
  license_file_2 = "./licenses/license2.lic"

  fgt_vnet_name = "demo-fgt-ha-4ports-vnet-fgt"

  fgt_subnet_names = {
    ha      = "demo-fgt-ha-4ports-subnet-ha"
    mgmt    = "demo-fgt-ha-4ports-subnet-mgmt"
    private = "demo-fgt-ha-4ports-subnet-private"
    public  = "demo-fgt-ha-4ports-subnet-public"
  }
  fgt_subnet_cidrs = {
    ha      = "172.30.0.0/26"
    mgmt    = "172.30.0.64/26"
    private = "172.30.0.192/26"
    public  = "172.30.0.128/26"
  }

  #-----------------------------------------------------------------------------------------------------
  # LB locals
  #-----------------------------------------------------------------------------------------------------
  config_gwlb        = false
  ilb_ip             = cidrhost(local.fgt_subnet_cidrs["private"], 7) // IP for internal LoadBalancer in private subnet
  backend-probe_port = "8008"
}






#-----------------------------------------------------------------------
# auto-generate variables and resources if not provided (NOT UPDATE)
#-----------------------------------------------------------------------

locals {
  #-----------------------------------------------------------------------------------------------------
  # vNet subnet locals 
  #-----------------------------------------------------------------------------------------------------
  fgt_subnet_ids = {
    ha      = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.fgt_vnet_name}/subnets/${local.fgt_subnet_names["ha"]}"
    mgmt    = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.fgt_vnet_name}/subnets/${local.fgt_subnet_names["mgmt"]}"
    private = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.fgt_vnet_name}/subnets/${local.fgt_subnet_names["private"]}"
    public  = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.fgt_vnet_name}/subnets/${local.fgt_subnet_names["public"]}"
  }
  fgt_vnet_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.fgt_vnet_name}"
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
  resource_group_name      = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
  location                 = local.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"

  tags = local.tags
}

// Create Resource Group if it is null
resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == null ? 1 : 0
  name     = "${local.prefix}-rg"
  location = local.location

  tags = local.tags
}