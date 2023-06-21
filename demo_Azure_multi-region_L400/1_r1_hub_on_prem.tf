#------------------------------------------------------------------
# FGT HUB 
# - Module cluster config
# - Extra config
# - Module FGT instances
# - Module FGT VNet
#------------------------------------------------------------------
// Create cluster config
module "r1_hub_on_prem_config" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-config_v2"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs       = module.r1_hub_on_prem_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r1_hub_on_prem_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r1_hub_on_prem_vnet.fgt-passive-ni_ips

  config_fgcp = local.r1_hub_on_prem_type == "fgcp" ? true : false
  config_fgsp = local.r1_hub_on_prem_type == "fgsp" ? true : false

  config_xlb = true
  ilb_ip     = local.r1_hub_on_prem_ilb_ip

  config_hub = true
  hub        = local.r1_hub_on_prem_sdwan

  fgt_active_extra-config  = join("\n", data.template_file.fgt_on_prem_s2s_config.*.rendered)
  fgt_passive_extra-config = join("\n", data.template_file.fgt_on_prem_s2s_config.*.rendered)

  vpc-spoke_cidr = [module.r1_hub_on_prem_vnet.subnet_cidrs["bastion"], local.r1_hub_azure_core_vnet_cidr, local.r2_hub_azure_core_vnet_cidr, local.r3_hub_azure_core_vnet_cidr]
}
data "template_file" "fgt_on_prem_s2s_config" {
  count    = length(local.r1_hub_on_prem_h2h)
  template = file("./templates/fgt_site-to-site.conf")
  vars = {
    id                = local.r1_hub_on_prem_h2h[count.index]["id"]
    remote_gw         = local.r1_hub_on_prem_h2h[count.index]["remote_gw"]
    local_gw          = local.r1_hub_on_prem_h2h[count.index]["vpn_port"] == "private" ? local.r1_hub_on_prem_ilb_ip : module.r1_hub_on_prem_xlb.elb_public-ip
    vpn_intf_id       = "${local.r1_hub_on_prem_h2h[count.index]["id"]}_ipsec_${count.index + 1}"
    vpn_remote_ip     = local.r1_hub_on_prem_h2h[count.index]["vpn_remote_ip"]
    vpn_local_ip      = local.r1_hub_on_prem_h2h[count.index]["vpn_local_ip"]
    vpn_cidr_mask     = cidrnetmask(local.r1_hub_on_prem_h2h[count.index]["vpn_cidr"])
    vpn_psk           = local.r1_hub_on_prem_h2h[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : local.r1_hub_on_prem_h2h[count.index]["vpn_psk"]
    vpn_port          = local.fgt_ports[local.r1_hub_on_prem_h2h[count.index]["vpn_port"]]
    ike_version       = local.r1_hub_on_prem_h2h[count.index]["ike_version"]
    dpd_retryinterval = local.r1_hub_on_prem_h2h[count.index]["dpd_retryinterval"]
    network_id        = local.r1_hub_on_prem_h2h[count.index]["network_id"]
    bgp_asn_remote    = local.r1_hub_on_prem_h2h[count.index]["bgp_asn_remote"]
    hck_ip            = local.r1_hub_on_prem_h2h[count.index]["hck_ip"]
    remote_cidr       = local.r1_hub_on_prem_h2h[count.index]["remote_cidr"]
    private_port      = local.fgt_ports["private"]
    count             = count.index + 1
  }
}
// Create FGT cluster as HUB-ADVPN
module "r1_hub_on_prem" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-r1-on-prem"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  size                     = local.fgt_size
  fgt_version              = local.fgt_version

  admin_username = local.admin_username
  admin_password = local.admin_password

  fgt-active-ni_ids  = module.r1_hub_on_prem_vnet.fgt-active-ni_ids
  fgt-passive-ni_ids = module.r1_hub_on_prem_vnet.fgt-passive-ni_ids
  fgt_config_1       = module.r1_hub_on_prem_config.fgt_config_1
  fgt_config_2       = module.r1_hub_on_prem_config.fgt_config_2

  fgt_passive = false
}
// Module VNET for FGT
module "r1_hub_on_prem_vnet" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-fgt_v2"

  prefix              = "${local.prefix}-r1-on-prem"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  vnet-fgt_cidr = local.r1_hub_on_prem_vnet_cidr
  admin_port    = local.admin_port
  admin_cidr    = local.admin_cidr

  accelerate = true
  config_xlb = true
}
#------------------------------------------------------------------
# Create Load Balancers
#------------------------------------------------------------------
module "r1_hub_on_prem_xlb" {
  depends_on = [module.r1_hub_on_prem_vnet]
  source     = "git::github.com/jmvigueras/modules//azure/xlb"

  prefix              = "${local.prefix}-r1-op"
  location            = local.region_1
  resource_group_name = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                = local.tags

  config_gwlb        = local.config_gwlb
  elb_floating_ip    = false
  ilb_floating_ip    = true
  ilb_ip             = local.r1_hub_on_prem_ilb_ip
  backend-probe_port = local.backend-probe_port

  vnet-fgt           = module.r1_hub_on_prem_vnet.vnet
  subnet_ids         = module.r1_hub_on_prem_vnet.subnet_ids
  subnet_cidrs       = module.r1_hub_on_prem_vnet.subnet_cidrs
  fgt-active-ni_ips  = module.r1_hub_on_prem_vnet.fgt-active-ni_ips
  fgt-passive-ni_ips = module.r1_hub_on_prem_vnet.fgt-passive-ni_ips
}
#------------------------------------------------------------------
# Create VM bastion
#------------------------------------------------------------------
module "r1_hub_on_prem_vm" {
  source = "git::github.com/jmvigueras/modules//azure/new-vm_rsa-ssh_v2"

  prefix                   = "${local.prefix}-r1-on-prem"
  location                 = local.region_1
  resource_group_name      = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_id   = module.r1_hub_on_prem_vnet.subnet_ids["bastion"]
  subnet_cidr = module.r1_hub_on_prem_vnet.subnet_cidrs["bastion"]
}
