locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  resource_group_name      = null                 // a new resource group will be created if null
  location                 = "francecentral"
  storage-account_endpoint = null                 // a new resource group will be created if null
  prefix = "demo-multi-cloud"   // prefix added to all resources created

  admin_port     = "8443"
  admin_cidr     = "${chomp(data.http.my-public-ip.body)}/32"
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  license_type = "payg"
  fgt_version  = "latest"
  fgt_size     = "Standard_F4"

  tags = {
    Deploy  = "module-fgt-ha-xlb"
    Project = "terraform-fortinet"
  }
  #-----------------------------------------------------------------------------------------------------
  # LB locals
  #-----------------------------------------------------------------------------------------------------
  ilb_ip             = cidrhost(module.fgt_hub_vnet.subnet_cidrs["private"], 9)
  backend-probe_port = "8008"

  config_gwlb        = false
  /*
  gwlb_ip =  cidrhost(module.fgt_spoke_vnet.subnet_cidrs["private"], 8)
  gwlb_vxlan = {
    vdi_ext  = "800"
    vdi_int  = "801"
    port_ext = "10800"
    port_int = "10801"
  }
  */
  #-----------------------------------------------------------------------------------------------------
  # FGT HUB locals
  #-----------------------------------------------------------------------------------------------------
  hub = {
    id                = "HUB-Az"
    bgp-asn_hub       = "65000"
    bgp-asn_spoke     = "65000"
    vpn_cidr          = "10.10.20.0/24"
    vpn_psk           = "secret-key-123"
    cidr              = "172.30.0.0/23"
    ike-version       = "2"
    network_id        = "1"
    dpd-retryinterval = "5"
    mode-cfg          = true
  }
  hub_peer_vxlan = {
    bgp-asn   = "65000"
    public-ip = data.terraform_remote_state.aws_fgt-ha-2az_hub-spoke_tgw.outputs.fgt_hub["fgt-1_public"]
    remote-ip = "10.10.30.1"
    local-ip  = "10.10.30.2"
    vni       = "1100"
  }

  fgt_vnet-spoke_cidrs  = ["172.30.100.0/23"]

  #-----------------------------------------------------------------------------------------------------
  # FAZ and FMG IPs
  #-----------------------------------------------------------------------------------------------------
  faz_ip = data.terraform_remote_state.aws_fgt-ha-2az_hub-spoke_tgw.outputs.faz["private_ip"]
  fmg_ip = data.terraform_remote_state.aws_fgt-ha-2az_hub-spoke_tgw.outputs.fmg["private_ip"]

  #-----------------------------------------------------------------------------------------------------
  # vWAN
  #-----------------------------------------------------------------------------------------------------
  vhub_cidr             = "172.30.10.0/23"
  vhub_vnet-spoke_cidrs = ["172.30.110.0/23"]
  #-----------------------------------------------------------------------------------------------------
  # Hubs
  #-----------------------------------------------------------------------------------------------------
  hubs = [
    {
      id                = local.hub["id"]
      bgp-asn           = local.hub["bgp-asn_hub"]
      public-ip         = module.fgt_hub_vnet.fgt-active-public-ip
      hub-ip            = cidrhost(cidrsubnet(local.hub["vpn_cidr"], 0, 0), 1)
      site-ip           = "" // set to "" if VPN mode-cfg is enable
      hck-srv-ip        = cidrhost(cidrsubnet(local.hub["vpn_cidr"], 0, 0), 1)
      vpn_psk           = local.hub["vpn_psk"]
      cidr              = local.hub["cidr"]
      ike-version       = local.hub["ike-version"]
      network_id        = local.hub["network_id"]
      dpd-retryinterval = local.hub["dpd-retryinterval"]
    }
  ]
}



#-----------------------------------------------------------------------------------------------------
# Import tfsate file from AWS and Azure deployment
#-----------------------------------------------------------------------------------------------------
// Import data from deployment aws_fgt-ha-2az_hub-spoke_tgw
data "terraform_remote_state" "aws_fgt-ha-2az_hub-spoke_tgw" {
  backend = "local"
  config = {
    path = "../aws_fgt-ha-2az_hub_tgw/terraform.tfstate"
  }
}

#-----------------------------------------------------------------------
# Necessary variables
#-----------------------------------------------------------------------
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