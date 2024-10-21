locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  resource_group_name = "fortigates-rg" // a new resource group will be created if null
  location            = "spaincentral"

  storage-account_endpoint = null    // a new resource group will be created if null
  prefix                   = "fortigates" // prefix added to all resources created

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
  fgt_version  = "7.2.9"

  #-----------------------------------------------------------------------------------------------------
  # VNet variables
  #-----------------------------------------------------------------------------------------------------
  // VNet name
  vnet_name = "fortigates-vnet-fgt" 
  // Fortigate Subnet Names
  vnet_subnet_names = {
    "public"  = "fortigates-subnet-public"
    "private" = "fortigates-subnet-private"
    "mgmt"    = "fortigates-subnet-hamgmt"
  }
  // Fortigate Subnet CIDRS
  vnet_subnet_cidrs = {
    "mgmt"    = "172.20.0.0/25"
    "private" = "172.20.1.0/25"
    "public"  = "172.20.0.128/25"
  }

  #-----------------------------------------------------------------------------------------------------
  # LB locals
  #-----------------------------------------------------------------------------------------------------
  // Port for backend health checks from LB
  backend-probe_port = "8008"
  // Internal LB IP
  ilb_ip             = cidrhost(local.vnet_subnet_cidrs["private"], 9)
  // List of listener for External LB
  elb_listeners = {
    "500"  = "Udp"
    "4500" = "Udp"
  }
}