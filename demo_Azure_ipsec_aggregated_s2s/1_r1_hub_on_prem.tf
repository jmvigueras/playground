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

  bgp_asn_default = local.r1_hub_on_prem_bgp_asn

  fgt_active_extra-config  = join("\n", data.template_file.fgt_on_prem_s2s_config.*.rendered, [data.template_file.fgt_on_prem_s2s_l3.rendered])
  fgt_passive_extra-config = join("\n", data.template_file.fgt_on_prem_s2s_config.*.rendered, [data.template_file.fgt_on_prem_s2s_l3.rendered])

  vpc-spoke_cidr = [local.r1_hub_on_prem_spoke_vnet_cidrs]
}
data "template_file" "fgt_on_prem_s2s_config" {
  count    = length(local.r1_hub_on_prem_h2h)
  template = file("./templates/fgt_s2s_ipsec.conf")
  vars = {
    remote_gw         = local.r1_hub_on_prem_h2h[count.index]["remote_gw"]
    local_gw          = local.r1_hub_on_prem_h2h[count.index]["vpn_port"] == "private" ? local.r1_hub_azure_core_ilb_ip : ""
    vpn_aggr_id       = "${local.r1_hub_on_prem_h2h[count.index]["id"]}-ipsec"
    vpn_intf_id       = "${local.r1_hub_on_prem_h2h[count.index]["id"]}-ipsec_${count.index + 1}"
    vpn_psk           = local.r1_hub_on_prem_h2h[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : local.r1_hub_on_prem_h2h[count.index]["vpn_psk"]
    vpn_port          = local.fgt_ports[local.r1_hub_on_prem_h2h[count.index]["vpn_port"]]
    ike_version       = local.r1_hub_on_prem_h2h[count.index]["ike_version"]
    dpd_retryinterval = local.r1_hub_on_prem_h2h[count.index]["dpd_retryinterval"]
    network_id        = local.r1_hub_on_prem_h2h[count.index]["network_id"]
  }
}
data "template_file" "fgt_on_prem_s2s_l3" {
  template = file("./templates/fgt_s2s_l3.conf")
  vars = {
    aggr_intf      = "${local.r1_hub_on_prem_h2h[0]["id"]}-ipsec"
    aggr_intf_ip   = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 0), 11)
    aggr_intf_mask = cidrnetmask(cidrsubnet(local.r1_to_r1_cidr, 2, 0))
    bgp_peer_asn   = local.r1_hub_azure_core_bgp_asn
    bgp_peer_ip    = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 0), 10)
    private_port   = local.fgt_ports["private"]
  }
}
// Create FGT cluster as HUB-ADVPN
module "r1_hub_on_prem" {
  source = "git::github.com/jmvigueras/modules//azure/fgt-ha"

  prefix                   = "${local.prefix}-r1-on-prem"
  location                 = local.region_1
  resource_group_name      = local.rg_name == null ? azurerm_resource_group.r1_rg[0].name : local.rg_name
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
  resource_group_name = local.rg_name == null ? azurerm_resource_group.r1_rg[0].name : local.rg_name
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
  resource_group_name = local.rg_name == null ? azurerm_resource_group.r1_rg[0].name : local.rg_name
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
# Create vNET spoke HUB
#------------------------------------------------------------------
// Create vNet spoke
module "r1_on_prem_vnet_spoke" {
  source = "git::github.com/jmvigueras/modules//azure/vnet-spoke_v2"

  prefix              = "${local.prefix}-r1-onprem"
  location            = local.region_1
  resource_group_name = local.rg_name == null ? azurerm_resource_group.r1_rg[0].name : local.rg_name
  tags                = local.tags

  vnet_spoke_cidr = local.r1_hub_on_prem_spoke_vnet_cidrs
  vnet_fgt        = module.r1_hub_on_prem_vnet.vnet
}
// Create VM in vNet spoke
module "r1_on_prem_vnet_spoke_vm" {
  source = "./modules/vm"
  count  = local.number_iperf_test

  prefix                   = "${local.prefix}-r1-onprem-${count.index + 1}"
  location                 = local.region_1
  resource_group_name      = local.rg_name == null ? azurerm_resource_group.r1_rg[0].name : local.rg_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.r1_storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint
  admin_username           = local.admin_username
  rsa-public-key           = trimspace(tls_private_key.ssh.public_key_openssh)

  vm_size = "Standard_D1_v2"

  subnet_id   = module.r1_on_prem_vnet_spoke.subnet_ids["subnet_1"]
  subnet_cidr = module.r1_on_prem_vnet_spoke.subnet_cidrs["subnet_1"]
  ni_ip       = cidrhost(module.r1_on_prem_vnet_spoke.subnet_cidrs["subnet_1"], 10 + count.index)

  user_data = data.template_file.r1_on_prem_vnet_spoke_vm[count.index].rendered
}
# Script to launch iperf3 test
data "template_file" "r1_on_prem_vnet_spoke_vm" {
  template = file("./templates/iperf_client.sh")
  count    = local.number_iperf_test
  vars = {
    server_ip = module.r1_hub_vnet_spoke_vm[count.index].vm["private_ip"]
  }
}
#------------------------------------------------------------------
# Create UDR in vNet spoke subnet 1 and 2 to iLB
#
// Route-table definition
resource "azurerm_route_table" "r1_on_prem_vnet_spoke_rt" {
  name                = "${local.prefix}-r1-hub-on-prem-vnet-spoke-rt"
  location            = local.region_1
  resource_group_name = local.rg_name == null ? azurerm_resource_group.r1_rg[0].name : local.rg_name

  disable_bgp_route_propagation = false

  route {
    name                   = "rfc1918-1"
    address_prefix         = "192.168.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.r1_hub_on_prem_ilb_ip
  }
  route {
    name                   = "rfc1918-2"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.r1_hub_on_prem_ilb_ip
  }
  route {
    name                   = "rfc1918-3"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.r1_hub_on_prem_ilb_ip
  }
  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}
// Route table association
resource "azurerm_subnet_route_table_association" "r1_on_prem_vnet_spoke_rta_subnet_1" {
  #count          = length(local.r1_hub_on_prem_spoke_vnet_cidrs)
  subnet_id      = module.r1_on_prem_vnet_spoke.subnet_ids["subnet_1"]
  route_table_id = azurerm_route_table.r1_on_prem_vnet_spoke_rt.id
}
// Route table association
resource "azurerm_subnet_route_table_association" "r1_on_prem_vnet_spoke_rta_subnet_2" {
  #count          = length(local.r1_hub_on_prem_spoke_vnet_cidrs)
  subnet_id      = module.r1_on_prem_vnet_spoke.subnet_ids["subnet_2"]
  route_table_id = azurerm_route_table.r1_on_prem_vnet_spoke_rt.id
}