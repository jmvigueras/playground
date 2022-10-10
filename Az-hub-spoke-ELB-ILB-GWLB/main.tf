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
    
    vnet-fgt_cidr         = var.hub["cidr"]
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

// Create ADVPN IPSEC PSK
resource "random_id" "advpn-psk-key" {
  byte_length = 20
}

// Create FGT cluster in region A (HUB1)
module "fgt-ha" {
    source = "./modules/fgt-ha"

    prefix           = var.prefix
    location         = var.location

    subscription_id  = var.fgt-subscription_id
    client_id        = var.fgt-client_id
    client_secret    = var.fgt-client_secret
    tenant_id        = var.fgt-tenant_id

    resourcegroup_name       = azurerm_resource_group.rg.name
    storage-account_endpoint = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint

    hub       = var.hub
    hub-peer  = var.hub-peer
    
    sites_bgp-asn         = var.sites_bgp-asn
    advpn-ipsec-psk       = random_id.advpn-psk-key.hex
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

    gwlb_ip             = cidrhost(module.vnet-fgt.subnet_cidrs["private"],15)

    spoke-vnet_cidrs     = module.vnet-spoke.vnet_cidrs
    spoke-subnet_cidrs   = module.vnet-spoke.subnet_cidrs

    fgt-active-ni_names   = module.vnet-fgt.fgt-active-ni_names
    fgt-passive-ni_names  = module.vnet-fgt.fgt-passive-ni_names

    cluster-public-ip_name    = module.vnet-fgt.cluster-public-ip_name
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
    vnet_id   = module.vnet-fgt.vnet_ids["vnet-fgt"]
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

// Create spoke site 1
module site1 {
  source = "./modules/site"

  prefix              = var.prefix
  location            = var.location
  resourcegroup_name  = azurerm_resource_group.rg.name
  storage-account_endpoint = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint

  subscription_id  = var.fgt-subscription_id
  client_id        = var.fgt-client_id
  client_secret    = var.fgt-client_secret
  tenant_id        = var.fgt-tenant_id

  adminusername    = var.adminusername
  adminpassword    = var.adminpassword
  admin_port       = var.admin_port
  admin_cidr       = var.admin_cidr
  
  site = {
    site_id         = "1"
    bgp-asn         = "65011"
    cidr            = cidrsubnet(var.spokes-onprem-cidr,4,1)
    advpn-ip1       = cidrhost(var.hub["advpn-net"],10)
    advpn-ip2       = cidrhost(var.hub-peer["advpn-net"],10)
  }

  hub1 = {
    bgp-asn         = var.hub["bgp-asn"]
    public-ip1      = module.lb.elb_public-ip
    advpn-ip1       = cidrhost(var.hub["advpn-net"],1)
    hck-srv-ip1     = module.vnet-spoke.ni_ips["spoke-1_subnet1"]
    hck-srv-ip2     = module.vnet-spoke.ni_ips["spoke-1_subnet2"]
    hck-srv-ip3     = module.vnet-spoke.ni_ips["spoke-2_subnet1"]
    cidr            = var.hub["cidr"]
    advpn-psk       = random_id.advpn-psk-key.hex
  }

  hub2 = {
    bgp-asn         = var.hub-peer["bgp-asn"]
    public-ip1      = var.hub-peer["public-ip1"]
    advpn-ip1       = cidrhost(var.hub-peer["advpn-net"],1)
    hck-srv-ip1     = var.hub-peer["hck-srv-ip1"]
    hck-srv-ip2     = var.hub-peer["hck-srv-ip2"]
    hck-srv-ip3     = var.hub-peer["hck-srv-ip3"]
    cidr            = var.hub-peer["cidr"]
    advpn-psk       = var.hub-peer["advpn-psk"]
  }
}


