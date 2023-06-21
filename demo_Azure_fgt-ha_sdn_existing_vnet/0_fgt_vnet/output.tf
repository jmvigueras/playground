output "resource_group_name" {
  value = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
}

output "vnet" {
  value = module.fgt_vnet.vnet
}

output "subnet_cidrs" {
  value = {
    mgmt      = module.fgt_vnet.subnet_cidrs["mgmt"]
    public    = module.fgt_vnet.subnet_cidrs["public"]
    private   = module.fgt_vnet.subnet_cidrs["private"]
    protected = module.fgt_vnet.subnet_cidrs["protected"]
  }
}

output "subnet_names" {
  value = {
    mgmt      = module.fgt_vnet.subnet_names["mgmt"]
    public    = module.fgt_vnet.subnet_names["public"]
    private   = module.fgt_vnet.subnet_names["private"]
    protected = module.fgt_vnet.subnet_names["protected"]
  }
}

output "subnet_ids" {
  value = {
    mgmt      = module.fgt_vnet.subnet_ids["mgmt"]
    public    = module.fgt_vnet.subnet_ids["public"]
    private   = module.fgt_vnet.subnet_ids["private"]
    protected = module.fgt_vnet.subnet_ids["protected"]
  }
}