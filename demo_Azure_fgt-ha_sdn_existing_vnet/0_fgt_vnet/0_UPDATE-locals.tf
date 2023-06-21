locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #----------------------------------------------------------------------------------------------------
  location                 = "francecentral"
  resource_group_name      = null           // a new resource group will be created if null
  storage-account_endpoint = null           // a new resource group will be created if null
  prefix                   = "demo-sdn-evo" // prefix added to all resources created

  tags = {
    Deploy  = "module-fgt-ha-xlb"
    Project = "terraform-fortinet"
  }

  fgt_vnet_cidr = "172.30.0.0/23"
}





// Create Resource Group if it is null
resource "azurerm_resource_group" "rg" {
  count    = local.resource_group_name == null ? 1 : 0
  name     = "${local.prefix}-rg"
  location = local.location

  tags = local.tags
}