// Create basic VNET and subnets
module "fgt_vnet" {
  source = "./modules/vnet"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.fgt_vnet_cidr
}