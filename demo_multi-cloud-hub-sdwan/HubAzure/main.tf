###################################################################
# Example of use of module
###################################################################
// Create FGT cluster as HUB-ADVPN
// (Example with a full scenario deployment with all modules)
module "fgt-ha" {
  depends_on = [module.xlb, module.vnet-fgt, module.rs]
  source     = "github.com/jmvigueras/modules//azure/fgt-ha-xlb-hub-sdwan-vwan"

  prefix                   = var.prefix
  location                 = var.location
  resourcegroup_name       = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags                     = var.tags
  storage-account_endpoint = var.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : var.storage-account_endpoint
  size                     = var.size

  adminusername = var.adminusername
  adminpassword = var.adminpassword
  admin_port    = var.admin_port
  admin_cidr    = var.admin_cidr

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  fgt-subnet_cidrs = module.vnet-fgt.subnet_cidrs
  fgt-active-ni_ids = [
    module.vnet-fgt.fgt-active-ni_ids["port1"],
    module.vnet-fgt.fgt-active-ni_ids["port2"],
    module.vnet-fgt.fgt-active-ni_ids["port3"]
  ]
  fgt-passive-ni_ids = [
    module.vnet-fgt.fgt-passive-ni_ids["port1"],
    module.vnet-fgt.fgt-passive-ni_ids["port2"],
    module.vnet-fgt.fgt-passive-ni_ids["port3"]
  ]
  gwlb_ip         = module.xlb.gwlb_ip
  rs_peers        = module.rs.rs_peers
  rs_bgp-asn      = module.rs.rs_bgp-asn
  vhub_peer       = null
  hub             = var.hub
  hub-peer_vxlan  = var.hub-peer_vxlan
  spoke_bgp-asn   = var.spoke_bgp-asn
  spoke_cidr_vnet = "172.16.0.0/12" // Complete CIDR range VNETs in Azure
}


###########################################################################
# Deploy complete architecture with other modules used as input in module
# - module vnet-fgt
# - module vnet-spoke
# - module site-spoke-to-2hubs
# - module xlb-fgt
# - module rs
############################################################################

// Module VNET spoke VNET FGT
// - This module will generate VNET spoke to connecto to VNET FGT
// - Module will peer VNET to VNET FGT
module "vnet-spoke-fgt" {
  depends_on = [module.vnet-fgt]
  source     = "github.com/jmvigueras/modules//azure/vnet-spoke"

  prefix             = "${var.prefix}-fgt"
  location           = var.location
  resourcegroup_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags               = var.tags

  vnet-spoke_cidrs = ["172.31.16.0/23"]
  vnet-fgt = {
    id   = module.vnet-fgt.vnet["id"]
    name = module.vnet-fgt.vnet["name"]
  }
}

// Module VNET for FGT
// - This module will generate VNET and network intefaces for FGT cluster
module "vnet-fgt" {
  source = "github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix             = var.prefix
  location           = var.location
  resourcegroup_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags               = var.tags

  vnet-fgt_cidr = "172.31.0.0/20"
  admin_port    = var.admin_port
  admin_cidr    = var.admin_cidr
}

// Create load balancers
module "xlb" {
  depends_on = [module.vnet-fgt]
  source     = "github.com/jmvigueras/modules//azure/xlb-fgt"

  prefix             = var.prefix
  location           = var.location
  resourcegroup_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags               = var.tags

  subnet_private = {
    cidr    = module.vnet-fgt.subnet_cidrs["private"]
    id      = module.vnet-fgt.subnet_ids["private"]
    vnet_id = module.vnet-fgt.vnet["id"]
  }

  fgt-ni_ids = {
    fgt1_public  = module.vnet-fgt.fgt-active-ni_ids["port2"]
    fgt1_private = module.vnet-fgt.fgt-active-ni_ids["port3"]
    fgt2_public  = module.vnet-fgt.fgt-passive-ni_ids["port2"]
    fgt2_private = module.vnet-fgt.fgt-passive-ni_ids["port3"]
  }

  fgt-ni_ips = {
    fgt1_public  = module.vnet-fgt.fgt-active-ni_ips["port2"]
    fgt1_private = module.vnet-fgt.fgt-active-ni_ips["port3"]
    fgt2_public  = module.vnet-fgt.fgt-passive-ni_ips["port2"]
    fgt2_private = module.vnet-fgt.fgt-passive-ni_ips["port3"]
  }
}

// Create load balancers
module "rs" {
  depends_on = [module.vnet-spoke-fgt, module.vnet-fgt]
  source     = "github.com/jmvigueras/modules//azure/routeserver"

  prefix             = var.prefix
  location           = var.location
  resourcegroup_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags               = var.tags

  subnet_ids   = module.vnet-spoke-fgt.subnet_ids["routeserver"]
  fgt_bgp-asn  = var.hub["bgp-asn"]
  fgt1_peer-ip = module.vnet-fgt.fgt-active-ni_ips["port3"]
  fgt2_peer-ip = module.vnet-fgt.fgt-passive-ni_ips["port3"]
}

// Create virtual machines
module "vms" {
  source = "github.com/jmvigueras/modules//azure/vm"

  prefix                   = var.prefix
  location                 = var.location
  resourcegroup_name       = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags                     = var.tags
  storage-account_endpoint = var.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : var.storage-account_endpoint
  adminusername            = var.adminusername
  adminpassword            = var.adminpassword

  vm_ni_ids = [
    module.vnet-spoke-fgt.ni_ids["subnet1"][0],
    module.vnet-spoke-fgt.ni_ids["subnet2"][0],
  ]
}


###################################################################
# Create necesary resources if not provided
###################################################################

// Create storage account if not provided
resource "random_id" "randomId" {
  count       = var.storage-account_endpoint == null ? 1 : 0
  byte_length = 8
}

resource "azurerm_storage_account" "storageaccount" {
  count                    = var.storage-account_endpoint == null ? 1 : 0
  name                     = "stgra${random_id.randomId[count.index].hex}"
  resource_group_name      = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  location                 = var.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"

  tags = var.tags
}

// Create Resource Group if it is null
resource "azurerm_resource_group" "rg" {
  count    = var.resourcegroup_name == null ? 1 : 0
  name     = "${var.prefix}-rg"
  location = var.location

  tags = var.tags
}



