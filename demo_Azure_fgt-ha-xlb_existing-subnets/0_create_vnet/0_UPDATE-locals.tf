locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  resource_group_name      = null // a new resource group will be created if null
  location                 = "spaincentral"
  storage-account_endpoint = null         // a new resource group will be created if null
  prefix                   = "fortigates" // prefix added to all resources created

  tags = {
    Deploy  = "module-fgt-ha-xlb"
    Project = "terraform-fortinet"
  }

  vnet_cidr  = "172.20.0.0/23"
  admin_cidr = "0.0.0.0/0"
  admin_port = "8443"
}

