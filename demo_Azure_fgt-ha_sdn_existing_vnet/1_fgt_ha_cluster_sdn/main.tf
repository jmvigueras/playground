#------------------------------------------------------------------
# Create FGT 
# - Create cluster FGCP config
# - Create FGCP instances
# - Create FGT extra config
# - Create VNet
#------------------------------------------------------------------
// Create Fortigate config
module "fgt_config" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-config_v2"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  # HA failover
  route_table          = "${local.prefix}-rt-protected"
  cluster_pip          = module.fgt_ni-nsg.fgt-active-public-name
  fgt-active-ni_names  = module.fgt_ni-nsg.fgt-active-ni_names
  fgt-passive-ni_names = module.fgt_ni-nsg.fgt-passive-ni_names
  #
  subnet_cidrs       = local.fgt_subnet_cidrs
  fgt-active-ni_ips  = module.fgt_ni-nsg.fgt-active-ni_ips
  fgt-passive-ni_ips = module.fgt_ni-nsg.fgt-passive-ni_ips

  license_type   = local.license_type
  license_file_1 = local.license_file_1
  license_file_2 = local.license_file_2

  fgt_active_extra-config  = data.template_file.fgt_active_extra_config.rendered
  fgt_passive_extra-config = data.template_file.fgt_passive_extra_config.rendered

  config_fgcp    = true
  vpc-spoke_cidr = [local.fgt_subnet_cidrs["protected"]]
}
// Extra config
// - SDN connector config for secondary IP
// - NAT outgoing firewall policies
data "template_file" "fgt_active_extra_config" {
  template = templatefile("./templates/fgt_extra_config.conf", {
    public_port   = local.fgt_ports["public"]
    private_port  = local.fgt_ports["private"]
    secondary_ip  = module.fgt_ni-nsg.fgt-active-ni_ips["public_2"]
    fgt_ni        = module.fgt_ni-nsg.fgt-active-ni_names["public"]
    secondary_pip = module.fgt_ni-nsg.fgt-active-public-name-2
    vm_ip_1       = cidrhost(local.fgt_subnet_cidrs["protected"], 10)
    vm_ip_2       = cidrhost(local.fgt_subnet_cidrs["protected"], 11)
  })
}
data "template_file" "fgt_passive_extra_config" {
  template = templatefile("./templates/fgt_extra_config.conf", {
    public_port   = local.fgt_ports["public"]
    private_port  = local.fgt_ports["private"]
    secondary_ip  = module.fgt_ni-nsg.fgt-passive-ni_ips["public_2"]
    fgt_ni        = module.fgt_ni-nsg.fgt-passive-ni_names["public"]
    secondary_pip = module.fgt_ni-nsg.fgt-active-public-name-2
    vm_ip_1       = cidrhost(local.fgt_subnet_cidrs["protected"], 10)
    vm_ip_2       = cidrhost(local.fgt_subnet_cidrs["protected"], 11)
  })
}
// Create FGT cluster spoke
module "fgt" {
  source = "./modules/fgt-ha"

  prefix                   = local.prefix
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.fgt_ni-nsg.fgt-active-ni_ids
  fgt-passive-ni_ids = module.fgt_ni-nsg.fgt-passive-ni_ids
  fgt_config_1       = module.fgt_config.fgt_config_1
  fgt_config_2       = module.fgt_config.fgt_config_2

  fgt_passive  = local.fgt_passive
  license_type = local.license_type
  fgt_version  = local.fgt_version
  size         = local.fgt_size
}
// Assing roles to FGT
data "azurerm_resource_group" "resource_group" {
  name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
}
resource "azurerm_role_assignment" "fgt_1" {
  scope                = data.azurerm_resource_group.resource_group.id
  role_definition_name = "Network Contributor"
  principal_id         = module.fgt.fgt-1_principal_id
}
resource "azurerm_role_assignment" "fgt_2" {
  count                = local.fgt_passive ? 1 : 0
  scope                = data.azurerm_resource_group.resource_group.id
  role_definition_name = "Network Contributor"
  principal_id         = module.fgt.fgt-2_principal_id
}
// Create FGT NIs and NSG
module "fgt_ni-nsg" {
  source = "./modules/fgt-ha_ni-nsg"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  subnet_cidrs = local.fgt_subnet_cidrs
  subnet_ids   = local.fgt_subnet_ids
  admin_port   = local.admin_port
  admin_cidr   = local.admin_cidr
}

#--------------------------------------------------------------------------------
# Create route table default (example of route table)
#--------------------------------------------------------------------------------
// Route-table definition
resource "azurerm_route_table" "rt-default" {
  name                = "${local.prefix}-rt-default"
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name

  disable_bgp_route_propagation = false

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.fgt_ni-nsg.fgt-active-ni_ips["private"]
  }
}

/*
#------------------------------------------------------------------
# Create VM test
#------------------------------------------------------------------
module "vm_test" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh_v2"
  count  = 2

  prefix                   = "${local.prefix}-test-${count.index + 1}"
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_id   = local.fgt_subnet_ids["protected"]
  subnet_cidr = local.fgt_subnet_cidrs["protected"]
  ni_ip       = cidrhost(local.fgt_subnet_cidrs["protected"], 10 + count.index)
}
*/