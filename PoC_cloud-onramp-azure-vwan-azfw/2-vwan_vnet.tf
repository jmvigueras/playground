#---------------------------------------------------------------------------------------
#Create connection new VNET spokes to vWAN and dynamic routing
#---------------------------------------------------------------------------------------
// Create new VNETs to connect to vWAN
// - This module will generate VNETs spoke to connect to vHUB
module "vwan_vnet-spoke" {
  source = "github.com/jmvigueras/modules//azure/vnet-spoke"

  prefix             = "${var.prefix}-vwan"
  location           = var.location
  resourcegroup_name = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags               = var.tags

  vnet-spoke_cidrs = var.vwan_new-vnet_cidr
  vnet-fgt         = null
}
// Create virtual machines
// - this module will create tests VM in VNETs where network interfaces are placed
module "vm_vhub-vnets" {
  source = "github.com/jmvigueras/modules//azure/vm"

  prefix                   = "${var.prefix}-vwan-spoke"
  location                 = var.location
  resourcegroup_name       = var.resourcegroup_name == null ? azurerm_resource_group.rg[0].name : var.resourcegroup_name
  tags                     = var.tags
  storage-account_endpoint = var.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : var.storage-account_endpoint
  adminusername            = var.adminusername
  rsa-public-key           = chomp(tls_private_key.ssh-rsa.public_key_openssh)
  vm_size                  = "Standard_B2s"

  vm_ni_ids = [
    module.vwan_vnet-spoke.ni_ids["subnet1"][0],
    module.vwan_vnet-spoke.ni_ids["subnet1"][1]
  ]
}

// Create new vHUB table route to associate to VNETs spoke in vWAN
resource "azurerm_virtual_hub_route_table" "vhub_route-table_vnet" {
  name           = "${var.prefix}-RT-VNET"
  virtual_hub_id = var.vhub_id
  labels         = ["${var.prefix}-RT-VNET"]

  route {
    name              = "default"
    destinations_type = "CIDR"
    destinations      = ["10.0.0.0/16", "192.168.0.0/16", "172.16.0.0/12", "0.0.0.0/0"]
    next_hop_type     = "ResourceId"
    next_hop          = var.azfw_id
  }
}
// Create connections to vWAN to provided VNETs
resource "azurerm_virtual_hub_connection" "vhub_connnection_vnet" {
  count                     = length(module.vwan_vnet-spoke.vnet_ids)
  name                      = "${var.prefix}-cx-vnet-${count.index + 1}"
  virtual_hub_id            = var.vhub_id
  remote_virtual_network_id = module.vwan_vnet-spoke.vnet_ids[count.index]

  routing {
    associated_route_table_id = azurerm_virtual_hub_route_table.vhub_route-table_vnet.id
    propagated_route_table {
      route_table_ids = [azurerm_virtual_hub_route_table.vhub_route-table_vnet.id]
      labels          = ["${var.prefix}-RT-VNET"]
    }
  }
}







