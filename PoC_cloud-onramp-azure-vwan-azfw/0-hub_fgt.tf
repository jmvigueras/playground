#-----------------------------------------------------------------------------
# Create fortigate cluster as HUB
# - Create a fortigate cluster that will act as testing HUB
# - Use module fgt-ha-hub (github.com/jmvigueras/modules//azure/fgt-ha-hub)
#-----------------------------------------------------------------------------
module "hub_fgt" {
  depends_on = [module.hub_vnet-fgt]
  source     = "github.com/jmvigueras/modules//azure/fgt-ha-hub"

  prefix                   = "${var.prefix}-hub"
  location                 = var.location
  resourcegroup_name       = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags                     = var.tags
  storage-account_endpoint = var.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : var.storage-account_endpoint

  adminusername = var.adminusername
  adminpassword = var.adminpassword
  admin_port    = var.admin_port
  admin_cidr    = var.admin_cidr
  // admin_cidr     = "${chomp(data.http.my-public-ip.body)}/32"
  rsa-public-key = chomp(tls_private_key.ssh-rsa.public_key_openssh)

  # Subnets details for VNET FGT (mandatory)
  fgt-subnet_cidrs = module.hub_vnet-fgt.subnet_cidrs

  # Detail for HUB configuration
  hub = var.hub_cloud

  # FGT active network interfaces (mandatory)
  fgt-active-ni_ids = [
    module.hub_vnet-fgt.fgt-active-ni_ids["port1"],
    module.hub_vnet-fgt.fgt-active-ni_ids["port2"],
    module.hub_vnet-fgt.fgt-active-ni_ids["port3"]
  ]
  fgt-passive-ni_ids = null
}


// Module VNET for FGT HUB
// - This module will generate VNET and network intefaces for FGT cluster
module "hub_vnet-fgt" {
  source = "github.com/jmvigueras/modules//azure/vnet-fgt"

  prefix             = "${var.prefix}-hub"
  location           = var.location
  resourcegroup_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags               = var.tags

  vnet-fgt_cidr = var.hub_cloud["cidr"]
  admin_port    = var.admin_port
  admin_cidr    = var.admin_cidr
  // admin_cidr    = "${chomp(data.http.my-public-ip.body)}/32" // (restrict access to user who deploys terrafom)
}

// Create virtual machines
// - this module will create tests VM in VNETs where network interfaces are placed
module "hub_vm" {
  source = "github.com/jmvigueras/modules//azure/vm"

  prefix                   = "${var.prefix}-hub"
  location                 = var.location
  resourcegroup_name       = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags                     = var.tags
  storage-account_endpoint = var.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : var.storage-account_endpoint
  adminusername            = var.adminusername
  rsa-public-key           = chomp(tls_private_key.ssh-rsa.public_key_openssh)
  vm_size                  = "Standard_B2s"

  vm_ni_ids = [
    module.hub_vnet-fgt.bastion-ni_id
  ]
}