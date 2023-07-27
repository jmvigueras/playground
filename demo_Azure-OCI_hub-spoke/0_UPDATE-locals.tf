locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables (Azure)
  #-----------------------------------------------------------------------------------------------------
  resource_group_name      = null // a new resource group will be created if null
  location                 = "francecentral"
  storage-account_endpoint = null           // a new resource group will be created if null
  prefix                   = "demo-cajamar" // prefix added to all resources created

  tags = {
    Deploy  = "cajamar"
    Project = "cajamar"
  }
  #-----------------------------------------------------------------------------------------------------
  # LB
  #-----------------------------------------------------------------------------------------------------
  config_gwlb        = false
  backend-probe_port = "8008"
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  admin_port     = "8443"
  admin_cidr     = "${chomp(data.http.my-public-ip.response_body)}/32"

  license_type = "payg"
  #-----------------------------------------------------------------------------------------------------
  # FGT HUB Azure
  #-----------------------------------------------------------------------------------------------------
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  fgt_size     = "Standard_F4s"
  fgt_version  = "7.2.5"

  hub_cluster_type = "fgcp"

  hub = [
    {
      id                = "HUBAZ"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.0.1.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.20.0.0/23"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # FGT Spoke OCI
  #-----------------------------------------------------------------------------------------------------
  spoke_cluster_type = "fgcp"

  spoke = {
    id      = "spoke-oci"
    cidr    = "10.10.0.0/24"
    bgp_asn = local.hub[0]["bgp_asn_spoke"]
  }

  hubs = concat(local.hubs_fgcp, local.hub_cluster_type == "fgsp" ? local.hubs_fgsp : [])

  hubs_fgcp = [for hub in local.hub :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? module.xlb.elb_public-ip : module.xlb.ilb_private-ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.hub_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], local.hub_cluster_type == "fgsp" ? 1 : 0, 0), 2)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.hub_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  hubs_fgsp = [for hub in local.hub :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? module.xlb.elb_public-ip : module.xlb.ilb_private-ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 2)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
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