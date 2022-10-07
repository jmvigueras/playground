// Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    environment = var.tag_env
  }
}

// Create VNET FGT
module "vnet-fgt" {
    source =  "./modules/vnet-fgt"

    prefix                = var.prefix
    location              = var.location
    resourcegroup_name    = azurerm_resource_group.rg.name
    
    vnet-fgt_cidr         = var.vnet-fgt_cidr
    admin_port            = var.admin_port
    admin_cidr            = var.admin_cidr
}

// Create VNETS Spoke 1 and 2
module "vnet-spoke" {
    source = "./modules/vnet-spoke"

    prefix                = var.prefix
    location              = var.location
    resourcegroup_name    = azurerm_resource_group.rg.name
    
    vnet-spoke-1_cidr    = var.vnet-spoke-1_cidr
    vnet-spoke-2_cidr    = var.vnet-spoke-2_cidr
}

// Create FGT cluster in region A
module "fgt-ha" {
    source = "./modules/fgt-ha"

    prefix           = var.prefix
    location         = var.location

    subscription_id  = var.subscription_id
    client_id        = var.client_id
    client_secret    = var.client_secret
    tenant_id        = var.tenant_id

    resourcegroup_name       = azurerm_resource_group.rg.name
    storage-account_endpoint = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint

    hub       = var.hub
    hub-peer  = var.hub-peer
    
    sites_bgp-asn         = var.sites_bgp-asn
    advpn-ipsec-psk       = var.advpn-ipsec-psk
    adminusername         = var.adminusername
    adminpassword         = var.adminpassword
    admin_port            = var.admin_port
    admin_cidr            = var.admin_cidr
    
    fgt-active-ni_ids  = [
      module.vnet-fgt.fgt-active-ni_ids["port1"],
      module.vnet-fgt.fgt-active-ni_ids["port2"],
      module.vnet-fgt.fgt-active-ni_ids["port3"]
    ]
    fgt-passive-ni_ids = [
      module.vnet-fgt.fgt-passive-ni_ids["port1"],
      module.vnet-fgt.fgt-passive-ni_ids["port2"],
      module.vnet-fgt.fgt-passive-ni_ids["port3"]
    ]
    fgt-ni-nsg_ids    = [
      module.vnet-fgt.nsg_ids["mgmt"], 
      module.vnet-fgt.nsg_ids["public"],
      module.vnet-fgt.nsg_ids["private"]
    ] 
    rs-spoke          = {
      rs1_ip1          = tolist(module.rs-spoke-1.rs_ips)[0]
      rs1_ip2          = tolist(module.rs-spoke-1.rs_ips)[1]
      rs1_bgp-asn      = "65515"
      rs2_ip1          = tolist(module.rs-spoke-2.rs_ips)[0]
      rs2_ip2          = tolist(module.rs-spoke-2.rs_ips)[1]
      rs2_bgp-asn      = "65515"
    }

    spoke-vnet_cidrs     = module.vnet-spoke.vnet_cidrs
    spoke-subnet_cidrs   = module.vnet-spoke.subnet_cidrs

    fgt-active-ni_names   = module.vnet-fgt.fgt-active-ni_names
    fgt-passive-ni_names  = module.vnet-fgt.fgt-passive-ni_names

    cluster-public-ip_name    = module.vnet-fgt.cluster-public-ip_name

    //rt-private_name       = azurerm_route_table.rt-vnet-fgt-private.name
}


module lb {
  source = "./modules/lb"

  prefix              = var.prefix
  location            = var.location
  resourcegroup_name  = azurerm_resource_group.rg.name

  backend-probe_port  = "8008"
  
  subnet-private = {
    cidr      = module.vnet-fgt.subnet_cidrs["private"]
    id        = module.vnet-fgt.subnet_ids["private"]
  }

  fgt-ni_ids = {
    fgt1-public     = module.vnet-fgt.fgt-active-ni_ids["port2"]
    fgt1-private    = module.vnet-fgt.fgt-active-ni_ids["port3"]
    fgt2-public     = module.vnet-fgt.fgt-passive-ni_ids["port2"]
    fgt2-private    = module.vnet-fgt.fgt-passive-ni_ids["port3"]
  }

  fgt-ni_ips = {
    fgt1-public     = module.vnet-fgt.fgt-active-ni_ips["port2"]
    fgt1-private    = module.vnet-fgt.fgt-active-ni_ips["port3"]
    fgt2-public     = module.vnet-fgt.fgt-passive-ni_ips["port2"]
    fgt2-private    = module.vnet-fgt.fgt-passive-ni_ips["port3"]
  }
}

module site1 {
  source = "./modules/site"

  prefix              = var.prefix
  location            = var.location
  resourcegroup_name  = azurerm_resource_group.rg.name
  storage-account_endpoint = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint

  subscription_id  = var.subscription_id
  client_id        = var.client_id
  client_secret    = var.client_secret
  tenant_id        = var.tenant_id

  adminusername    = var.adminusername
  adminpassword    = var.adminpassword
  admin_port       = var.admin_port
  admin_cidr       = var.admin_cidr
  
  site = {
    site_id         = "1"
    cidr            = "192.168.0.0/20"
    bgp-asn         = "65011"
    advpn-ip1       = "10.10.10.10"
    advpn-ip2       = "10.10.20.10"
  }

  hub2 = {
    bgp-asn         = "65002"
    public-ip1      = "20.19.210.54"
    advpn-ip1       = "10.10.20.1"
    hck-srv-ip1     = module.vnet-spoke.ni_ips["spoke-1_subnet1"]
    hck-srv-ip2     = module.vnet-spoke.ni_ips["spoke-1_subnet2"]
    hck-srv-ip3     = module.vnet-spoke.ni_ips["spoke-2_subnet1"]
    cidr            = var.vnet-fgt_cidr
  }
}


