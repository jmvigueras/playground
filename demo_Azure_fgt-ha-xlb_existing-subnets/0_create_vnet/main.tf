// Create Resource Group if it is null
resource "azurerm_resource_group" "rg" {
  count    = local.resource_group_name == null ? 1 : 0
  name     = "${local.prefix}-rg"
  location = local.location

  tags = local.tags
}
// Module VNET for FGT
// - This module will generate VNET and network intefaces for FGT cluster
module "vnet" {
  source  = "./modules/vnet-fgt"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.vnet_cidr
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr

  config_xlb = true // module variable to associate a public IP to fortigate's public interface (when using External LB, true means not to configure a public IP)
}
