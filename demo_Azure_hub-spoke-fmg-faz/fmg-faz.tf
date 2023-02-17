
#------------------------------------------------------------------------------
# Create FAZ and FMG
#------------------------------------------------------------------------------
// Create FAZ
module "faz" {
  source = "github.com/jmvigueras/modules//azure/faz"

  prefix                   = local.prefix
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fmg-faz_size

  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)
  license_type   = local.fmg-faz_license_type
  license_file   = local.faz_license_file

  admin_username = local.admin_username
  admin_password = local.admin_password

  faz_ni_ids = module.fgt_hub_vnet.faz_ni_ids
  faz_ni_ips = module.fgt_hub_vnet.faz_ni_ips
  subnet_cidrs = {
    public  = module.fgt_hub_vnet.subnet_cidrs["public"]
    private = module.fgt_hub_vnet.subnet_cidrs["bastion"]
  }
}
// Create FMG
module "fmg" {
  source = "github.com/jmvigueras/modules//azure/fmg"

  prefix                   = local.prefix
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fmg-faz_size

  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)
  license_type   = local.fmg-faz_license_type
  license_file   = local.fmg_license_file

  admin_username = local.admin_username
  admin_password = local.admin_password

  fmg_ni_ids = module.fgt_hub_vnet.fmg_ni_ids
  fmg_ni_ips = module.fgt_hub_vnet.fmg_ni_ips
  subnet_cidrs = {
    public  = module.fgt_hub_vnet.subnet_cidrs["public"]
    private = module.fgt_hub_vnet.subnet_cidrs["bastion"]
  }
}




