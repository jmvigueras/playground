locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  resource_group_name      = null // a new resource group will be created if null
  location                 = "francecentral"
  storage-account_endpoint = null       // a new resource group will be created if null
  prefix                   = "demo-xlb" // prefix added to all resources created

  tags = {
    Deploy  = "demo-fgt-xlb"
    Project = "terraform-fortinet"
  }
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  admin_port = "8443"
  //admin_cidrs   = ["${chomp(data.http.my-public-ip.response_body)}/32"]
  admin_cidrs    = ["0.0.0.0/0"]
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  fgt_cluster_mode = "fgcp"

  license_type  = "byol"
  fgt_1_license = "./licenses/license1.lic"
  fgt_2_license = "./licenses/license2.lic"

  fgt_size      = "Standard_F4s"
  fgt_version   = "7.2.5"
  fgt_vnet_cidr = "172.30.0.0/24"
  fgt_vnet_peer = [] // cidrs list of vnet or subnets reached througth internal port

  #-----------------------------------------------------------------------------------------------------
  # LB locals
  #-----------------------------------------------------------------------------------------------------
  ilb_ip             = cidrhost(module.fgt_vnet.subnet_cidrs["private"], 9)
  ilb_erc            = cidrhost(module.fgt_vnet.subnet_cidrs["erc"], 9)
  backend-probe_port = "8008"
}




