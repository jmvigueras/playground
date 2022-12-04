#--------------------------------------------------------------------------------------
# Example of use of module
# - it will deploy fortigate (FGT) cluster as site spoke to HUB (configure "ha = true" in site var definition for FGT HA)
# - it will use another module to create necessary VNET
# - it will use another module to create VM bastion for testing
#--------------------------------------------------------------------------------------

// Create fortigate cluster onramp
module "onramp_fgt" {
  depends_on = [module.onramp_vnet-fgt]
  source     = "github.com/jmvigueras/modules//azure/fgt-ha-spoke-sdwan"

  prefix                   = var.prefix
  location                 = var.location
  resourcegroup_name       = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags                     = var.tags
  storage-account_endpoint = var.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : var.storage-account_endpoint

  adminusername  = var.adminusername
  adminpassword  = var.adminpassword
  admin_port     = var.admin_port
  admin_cidr     = var.admin_cidr
  rsa-public-key = chomp(tls_private_key.ssh-rsa.public_key_openssh)

  # Subnets details for VNET FGT (mandatory)
  fgt-subnet_cidrs = module.onramp_vnet-fgt.subnet_cidrs

  # Site configuration defined in vars_hubs.tf (mandatory)
  site = var.site_onramp

  # Configure SDWAN to HUB in vars_hubs.tf (optional)
  # hubs = var.hubs // uncomment for using HUB configuration in var.hubs describe on 1-onramp_vars.tf
  hubs = [
    {
      id         = module.hub_fgt.hub["id"]
      bgp-asn    = module.hub_fgt.hub["bgp-asn"]
      public-ip  = module.hub_vnet-fgt.cluster-public-ip_ip
      hub-ip     = module.hub_fgt.hub["hub-ip"]
      site-ip    = module.hub_fgt.hub["site-ip"]
      hck-srv-ip = module.hub_fgt.hub["hck-srv-ip"]
      advpn-psk  = module.hub_fgt.hub["advpn-psk"]
      cidr       = module.hub_fgt.hub["cidr"]
    }
  ]

  # Configure BGP to vHUB (optional)
  vhub_peer = var.vhub_peer-ip

  # Configure SDN connector (optional)
  #subscription_id = var.subscription_id
  #client_id       = var.client_id
  #client_secret   = var.client_secret
  #tenant_id       = var.tenant_id

  # FGT active network interfaces (mandatory)
  fgt-active-ni_ids = [
    module.onramp_vnet-fgt.fgt-active-ni_ids["port1"],
    module.onramp_vnet-fgt.fgt-active-ni_ids["port2"],
    module.onramp_vnet-fgt.fgt-active-ni_ids["port3"]
  ]
  # FGT passive network interfaces (mandatory/optional)
  # - Mandatory if you have set ha=true in site definition in vars_hubs.tf
  fgt-passive-ni_ids = [
    module.onramp_vnet-fgt.fgt-passive-ni_ids["port1"],
    module.onramp_vnet-fgt.fgt-passive-ni_ids["port2"],
    module.onramp_vnet-fgt.fgt-passive-ni_ids["port3"]
  ]
}


#--------------------------------------------------------------------------------------
# Deploy complete architecture with other modules used as input in module
# - module vnet-fgt (github.com/jmvigueras/modules//azure/vnet-fgt)
# - module vm (github.com/jmvigueras/modules//azure/vm)
#--------------------------------------------------------------------------------------

// Module VNET for FGT SITE
// - This module will generate VNET and network intefaces for FGT cluster
module "onramp_vnet-fgt" {
  source = "github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix             = "${var.prefix}-onramp"
  location           = var.location
  resourcegroup_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags               = var.tags

  vnet-fgt_cidr = var.site_onramp["cidr"]
  admin_port    = var.admin_port
  admin_cidr    = var.admin_cidr
  // admin_cidr    = "${chomp(data.http.my-public-ip.body)}/32" (restrict access to user who deploys terrafom)
}

// Create virtual machines
// - this module will create tests VM in VNETs where network interfaces are placed
module "onramp_vm" {
  source = "github.com/jmvigueras/modules//azure/vm"

  prefix                   = "${var.prefix}-onramp"
  location                 = var.location
  resourcegroup_name       = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags                     = var.tags
  storage-account_endpoint = var.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : var.storage-account_endpoint
  adminusername            = var.adminusername
  rsa-public-key           = chomp(tls_private_key.ssh-rsa.public_key_openssh)
  vm_size                  = "Standard_B2s"

  vm_ni_ids = [
    module.onramp_vnet-fgt.bastion-ni_id
  ]
}

