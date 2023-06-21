#------------------------------------------------------------------
# FGT HUB 
# - Module cluster config
# - Extra config
# - Module FGT instances
# - Module FGT VNet
#------------------------------------------------------------------
// Create cluster config
module "r3_hub_azure_core_config" {
  depends_on = [module.r3_hub_azure_xlb]
  source     = "git::github.com/jmvigueras/modules//azure/fgt-config_v2"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs       = module.r3_hub_azure_core_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r3_hub_azure_core_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r3_hub_azure_core_vnet.fgt-passive-ni_ips

  config_fgcp = local.r3_hub_azure_core_type == "fgcp" ? true : false
  config_fgsp = local.r3_hub_azure_core_type == "fgsp" ? true : false

  config_xlb = true
  ilb_ip     = local.r3_hub_azure_core_ilb_ip
  //elb_ip     = module.r3_hub_azure_xlb.elb_public-ip

  config_hub = true
  hub        = local.r3_hub_azure_sdwan

  bgp_asn_default = local.r3_hub_azure_core_bgp_asn

  fgt_active_extra-config  = join("\n", data.template_file.r3_azure_s2s_config.*.rendered)
  fgt_passive_extra-config = join("\n", data.template_file.r3_azure_s2s_config.*.rendered)

  vpc-spoke_cidr = [module.r3_hub_azure_core_vnet.subnet_cidrs["bastion"], local.r1_hub_azure_core_vnet_cidr, local.r1_hub_on_prem_vnet_cidr, local.r2_hub_azure_core_vnet_cidr]
}
data "template_file" "r3_azure_s2s_config" {
  count    = length(local.r3_hub_azure_core_h2h)
  template = file("./templates/fgt_site-to-site.conf")
  vars = {
    id                = local.r3_hub_azure_core_h2h[count.index]["id"]
    remote_gw         = local.r3_hub_azure_core_h2h[count.index]["remote_gw"]
    local_gw          = local.r3_hub_azure_core_h2h[count.index]["vpn_port"] == "private" ? local.r3_hub_azure_core_ilb_ip : module.r3_hub_azure_xlb.elb_public-ip
    vpn_intf_id       = "${local.r3_hub_azure_core_h2h[count.index]["id"]}_ipsec_${count.index + 1}"
    vpn_remote_ip     = local.r3_hub_azure_core_h2h[count.index]["vpn_remote_ip"]
    vpn_local_ip      = local.r3_hub_azure_core_h2h[count.index]["vpn_local_ip"]
    vpn_cidr_mask     = cidrnetmask(local.r3_hub_azure_core_h2h[count.index]["vpn_cidr"])
    vpn_psk           = local.r3_hub_azure_core_h2h[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : local.r3_hub_azure_core_h2h[count.index]["vpn_psk"]
    vpn_port          = local.fgt_ports[local.r3_hub_azure_core_h2h[count.index]["vpn_port"]]
    ike_version       = local.r3_hub_azure_core_h2h[count.index]["ike_version"]
    dpd_retryinterval = local.r3_hub_azure_core_h2h[count.index]["dpd_retryinterval"]
    network_id        = local.r3_hub_azure_core_h2h[count.index]["network_id"]
    bgp_asn_remote    = local.r3_hub_azure_core_h2h[count.index]["bgp_asn_remote"]
    hck_ip            = local.r3_hub_azure_core_h2h[count.index]["hck_ip"]
    remote_cidr       = local.r3_hub_azure_core_h2h[count.index]["remote_cidr"]
    private_port      = local.fgt_ports["private"]
    count             = count.index + 1
  }
}
// Create FGT cluster as HUB-ADVPN
module "r3_hub_azure_core" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-r3-hub"
  location                 = local.region_3
  resource_group_name      = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r3_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fgt_size
  fgt_version              = local.fgt_version

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.r3_hub_azure_core_vnet.fgt-active-ni_ids
  fgt-passive-ni_ids = module.r3_hub_azure_core_vnet.fgt-passive-ni_ids
  fgt_config_1       = module.r3_hub_azure_core_config.fgt_config_1
  fgt_config_2       = module.r3_hub_azure_core_config.fgt_config_2

  fgt_passive = false
}
// Module VNET for FGT
module "r3_hub_azure_core_vnet" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt_v2"

  prefix              = "${local.prefix}-r3-hub"
  location            = local.region_3
  resource_group_name = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.r3_hub_azure_core_vnet_cidr
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr

  accelerate = true
  config_xlb = true
}

#------------------------------------------------------------------
# - Create Load Balancers
# - Create VNet spoke peered to VNet FGT
# - Create VM in VNet spoke
#------------------------------------------------------------------
// Create load balancers
module "r3_hub_azure_xlb" {
  depends_on = [module.r3_hub_azure_core_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/xlb"

  prefix              = "${local.prefix}-r3"
  location            = local.region_3
  resource_group_name = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name
  tags                = local.tags

  config_gwlb        = local.config_gwlb
  elb_floating_ip    = false
  ilb_floating_ip    = true
  ilb_ip             = local.r3_hub_azure_core_ilb_ip
  backend-probe_port = local.backend-probe_port

  vnet-fgt           = module.r3_hub_azure_core_vnet.vnet
  subnet_ids         = module.r3_hub_azure_core_vnet.subnet_ids
  subnet_cidrs       = module.r3_hub_azure_core_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r3_hub_azure_core_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r3_hub_azure_core_vnet.fgt-passive-ni_ips
}
// Create vNet spoke
module "r3_hub_vnet_spoke" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-spoke_v2"
  count  = length(local.r3_hub_azure_spoke_vnet_cidrs)

  prefix              = "${local.prefix}-r3-${count.index + 1}"
  location            = local.region_3
  resource_group_name = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name
  tags                = local.tags

  vnet_spoke_cidr = local.r3_hub_azure_spoke_vnet_cidrs[count.index]
  vnet_fgt        = module.r3_hub_azure_core_vnet.vnet
}
// Create VM in vNet spoke
module "r3_hub_vnet_spoke_vm" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh_v2"
  count  = length(local.r3_hub_azure_spoke_vnet_cidrs)

  prefix                   = "${local.prefix}-r3-hub-vnet-spoke"
  location                 = local.region_3
  resource_group_name      = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r3_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_id   = module.r3_hub_vnet_spoke[count.index].subnet_ids["subnet_1"]
  subnet_cidr = module.r3_hub_vnet_spoke[count.index].subnet_cidrs["subnet_1"]
}

#--------------------------------------------------------------------------------
# Create UDR in vNet spoke subnet 1 and 2 to iLB
#--------------------------------------------------------------------------------
// Route-table definition
resource "azurerm_route_table" "r3_hub_vnet_spoke_rt" {
  name                = "${local.prefix}-r3-hub-vnet-spoke-rt"
  location            = local.region_3
  resource_group_name = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name

  disable_bgp_route_propagation = false

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.r3_hub_azure_core_ilb_ip
  }
  route {
    name           = "admin-cdir"
    address_prefix = local.admin_cidr
    next_hop_type  = "Internet"
  }
}
// Route table association
resource "azurerm_subnet_route_table_association" "r3_hub_vnet_spoke_rta_subnet_1" {
  count          = length(local.r3_hub_azure_spoke_vnet_cidrs)
  subnet_id      = module.r3_hub_vnet_spoke[count.index].subnet_ids["subnet_1"]
  route_table_id = azurerm_route_table.r3_hub_vnet_spoke_rt.id
}
// Route table association
resource "azurerm_subnet_route_table_association" "r3_hub_vnet_spoke_rta_subnet_2" {
  count          = length(local.r3_hub_azure_spoke_vnet_cidrs)
  subnet_id      = module.r3_hub_vnet_spoke[count.index].subnet_ids["subnet_2"]
  route_table_id = azurerm_route_table.r3_hub_vnet_spoke_rt.id
}


