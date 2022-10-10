// Create Resource Group
resource "azurerm_resource_group" "rg-regiona" {
  name     = "${var.prefix}-rg"
  location = var.regiona

  tags = {
    environment = var.tag_env
  }
}

// Create VNET FGT
module "vnet-fgt" {
    source =  "github.com/jmvigueras/playground/SecDayMad//modules/hubAzure/modules/vnet-fgt"

    prefix                = var.prefix
    location              = var.regiona
    resourcegroup_name    = azurerm_resource_group.rg-regiona.name
    
    vnet-fgt_net        = var.vnet-fgt_net
    admin_port          = var.admin_port
    admin_cidr          = var.admin_cidr
}

// Create VNETS Spoke 1 and 2
module "vnet-spoke" {
    source = "github.com/jmvigueras/playground/SecDayMad//modules/hubAzure/modules/vnet-spoke"

    prefix                = var.prefix
    location              = var.regiona
    resourcegroup_name    = azurerm_resource_group.rg-regiona.name
    
    vnet-spoke-1_net    = var.vnet-spoke-1_net
    vnet-spoke-2_net    = var.vnet-spoke-2_net
}

// Create FGT cluster in region A
module "fgt-ha" {
    source = "github.com/jmvigueras/playground/SecDayMad//modules/hubAzure/modules/fgt-ha"

    prefix           = var.prefix
    location         = var.regiona

    subscription_id  = var.subscription_id
    client_id        = var.client_id
    client_secret    = var.client_secret
    tenant_id        = var.tenant_id
    bootstrap-fgt    = var.bootstrap-fgt

    resourcegroup_name       = azurerm_resource_group.rg-regiona.name
    storage-account_endpoint = azurerm_storage_account.fgtstorageaccount-regiona.primary_blob_endpoint

    hub       = var.hub
    hub-peer  = var.hub-peer
    
    sites_bgp-asn         = var.sites_bgp-asn
    advpn-ipsec-psk       = var.advpn-ipsec-psk
    adminusername         = var.adminusername
    adminpassword         = var.adminpassword
    admin_port            = var.admin_port
    admin_cidr            = var.admin_cidr
    
    fgt-active-ni_ids     = [
      module.vnet-fgt.fgt-active-ni_ids["port1"],
      module.vnet-fgt.fgt-active-ni_ids["port2"],
      module.vnet-fgt.fgt-active-ni_ids["port3"]
    ]
    fgt-passive-ni_ids    = [
      module.vnet-fgt.fgt-passive-ni_ids["port1"],
      module.vnet-fgt.fgt-passive-ni_ids["port2"],
      module.vnet-fgt.fgt-passive-ni_ids["port3"]
    ]
    fgt-ni-nsg_ids        = [
      module.vnet-fgt.nsg_ids["mgmt"], 
      module.vnet-fgt.nsg_ids["public"],
      module.vnet-fgt.nsg_ids["private"]
    ]  

    fgt-active-ni_names   = module.vnet-fgt.fgt-active-ni_names
    fgt-passive-ni_names  = module.vnet-fgt.fgt-passive-ni_names

    cluster-public-ip_name    = module.vnet-fgt.cluster-public-ip_name

    rt-private_name       = azurerm_route_table.rt-vnet-fgt-private.name
    rt-spoke_name         = azurerm_route_table.rt-vnet-spoke-vm.name
}


