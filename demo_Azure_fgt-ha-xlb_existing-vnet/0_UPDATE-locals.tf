locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  resource_group_name      = "RG-HUB-HSJDBCN" // a new resource group will be created if null
  location                 = "westeurope"
  
  storage-account_endpoint = null                 // a new resource group will be created if null
  prefix                   = "snet-forti-hsjdbcn" // prefix added to all resources created

  tags = {
    Deploy  = "Secure VNet Fortinet"
    Project = "snet-forti"
  }
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  admin_port     = "8443"
  admin_cidr     = "0.0.0.0/0"
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  license_type = "byol"
  fgt_size     = "Standard_F4s"
  fgt_version  = "7.2.8"

  fgt_vnet = {
    name = "vnet-hub-hsjdbcn"
    cidr = "10.0.144.0/23"
    id   = "b83e2f13-aa61-475c-xxxxx"
  }

  fgt_vnet_subnets = {
    "public"  = "10.0.144.224/27"
    "private" = "10.0.144.192/27"
    "mgmt"    = "10.0.144.128/27"
  }

  #-----------------------------------------------------------------------------------------------------
  # LB locals
  #-----------------------------------------------------------------------------------------------------
  ilb_ip             = cidrhost(module.fgt_vnet.subnet_cidrs["private"], 9)
  backend-probe_port = "8008"
}


