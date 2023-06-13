#--------------------------------------------------------------------------------
# Create VNets peering between HUBs (region 1 to region 2)
# - HUB to HUB
# - HUB to on-prem
#--------------------------------------------------------------------------------
// VNet peering to HUB to HUB
resource "azurerm_virtual_network_peering" "r1-to-r2-peer-hub-to-hub-1" {
  depends_on                = [module.r2_hub_azure_core_vnet, module.r1_hub_azure_core_vnet]
  name                      = "r1-to-r2-peer-hub-to-hub"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r2_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r1-to-r2-peer-hub-to-hub-2" {
  depends_on                = [module.r2_hub_azure_core_vnet, module.r1_hub_azure_core_vnet]
  name                      = "r1-to-r2-peer-hub-to-hub"
  resource_group_name       = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  virtual_network_name      = module.r2_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
// VNet peering to HUB to on-prem
resource "azurerm_virtual_network_peering" "r1-to-r2-peer-hub-to-on-prem-1" {
  depends_on                = [module.r2_hub_azure_core_vnet, module.r1_hub_on_prem_vnet]
  name                      = "r1-to-r2-peer-hub-to-on-prem"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_on_prem_vnet.vnet["name"]
  remote_virtual_network_id = module.r2_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r1-to-r2-peer-hub-to-on-prem-2" {
  depends_on                = [module.r2_hub_azure_core_vnet, module.r1_hub_on_prem_vnet]
  name                      = "r1-to-r2-peer-hub-to-on-prem"
  resource_group_name       = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  virtual_network_name      = module.r2_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_hub_on_prem_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
#--------------------------------------------------------------------------------
# Create VNets peering between HUB Azure and HUB on-prem (region 1)
# - HUB to on-prem
#--------------------------------------------------------------------------------
// VNet peering to HUB Azure SDWAN
resource "azurerm_virtual_network_peering" "r1-to-r1-peer-core-to-on-prem-1" {
  depends_on                = [module.r1_hub_azure_core_vnet, module.r1_hub_on_prem_vnet]
  name                      = "r1-to-r1-core-to-on-prem"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_hub_on_prem_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r1-to-r1-peer-core-to-on-prem-2" {
  depends_on                = [module.r1_hub_azure_core_vnet, module.r1_hub_on_prem_vnet]
  name                      = "r1-to-r1-core-to-on-prem"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_on_prem_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
#--------------------------------------------------------------------------------
# Create VNets peering between HUB Azure and SDWAN VNet (region 1)
# - HUB to on-prem
#--------------------------------------------------------------------------------
// VNet peering Core to SDWAN
resource "azurerm_virtual_network_peering" "r1-to-r1-peer-core-to-sdwan-1" {
  depends_on                = [module.r1_hub_azure_core_vnet, module.r1_hub_on_prem_vnet]
  name                      = "r1-to-r1-peer-core-to-sdwan"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_hub_azure_sdwan_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r1-to-r1-peer-core-to-sdwan-2" {
  depends_on                = [module.r1_hub_azure_core_vnet, module.r1_hub_on_prem_vnet]
  name                      = "r1-to-r1-peer-core-to-sdwan"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_azure_sdwan_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
#--------------------------------------------------------------------------------
# Create VNets peering between HUBs (region 1 to region 3)
# - HUB to HUB
# - HUB to on-prem
#--------------------------------------------------------------------------------
// VNet peering to HUB to HUB
resource "azurerm_virtual_network_peering" "r1-to-r3-peer-hub-to-hub-1" {
  depends_on                = [module.r3_hub_azure_core_vnet, module.r1_hub_azure_core_vnet]
  name                      = "r1-to-r3-peer-hub-to-hub"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r3_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r1-to-r3-peer-hub-to-hub-2" {
  depends_on                = [module.r3_hub_azure_core_vnet, module.r1_hub_azure_core_vnet]
  name                      = "r1-to-r3-peer-hub-to-hub"
  resource_group_name       = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name
  virtual_network_name      = module.r3_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
// VNet peering to HUB to on-prem
resource "azurerm_virtual_network_peering" "r1-to-r3-peer-hub-to-on-prem-1" {
  depends_on                = [module.r3_hub_azure_core_vnet, module.r1_hub_on_prem_vnet]
  name                      = "r1-to-r3-peer-hub-to-on-prem"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_on_prem_vnet.vnet["name"]
  remote_virtual_network_id = module.r3_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r1-to-r3-peer-hub-to-on-prem-2" {
  depends_on                = [module.r3_hub_azure_core_vnet, module.r1_hub_on_prem_vnet]
  name                      = "r1-to-r3-peer-hub-to-on-prem"
  resource_group_name       = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name
  virtual_network_name      = module.r3_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_hub_on_prem_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
#--------------------------------------------------------------------------------
# Create VNets peering between Spokes and SDWAN HUBs (region 1)
# - Spoke to Azure SDWAN
# - Spoke to On-prem
#--------------------------------------------------------------------------------
// VNet peering to HUB Azure SDWAN
resource "azurerm_virtual_network_peering" "r1-peer-spoke-to-azure-sdwan-1" {
  depends_on                = [module.r1_hub_azure_sdwan_vnet, module.r1_spoke_vnet]
  count                     = local.r1_spoke_number
  name                      = "r1-peer-spoke-${count.index + 1}-to-sdwan"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_spoke_vnet[count.index].vnet["name"]
  remote_virtual_network_id = module.r1_hub_azure_sdwan_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r1-peer-spoke-to-azure-sdwan-2" {
  depends_on                = [module.r1_hub_azure_sdwan_vnet, module.r1_spoke_vnet]
  count                     = local.r1_spoke_number
  name                      = "r1-peer-spoke-${count.index + 1}-to-sdwan"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_azure_sdwan_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_spoke_vnet[count.index].vnet["id"]
  allow_forwarded_traffic   = true
}
// VNet peering to HUB on-premises
resource "azurerm_virtual_network_peering" "r1-peer-spoke-to-on-prem-1" {
  depends_on                = [module.r1_hub_on_prem_vnet, module.r1_spoke_vnet]
  count                     = local.r1_spoke_number
  name                      = "r1-peer-spoke-${count.index + 1}-to-on-prem"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_spoke_vnet[count.index].vnet["name"]
  remote_virtual_network_id = module.r1_hub_on_prem_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r1-peer-spoke-to-on-prem-2" {
  depends_on                = [module.r1_hub_on_prem_vnet, module.r1_spoke_vnet]
  count                     = local.r1_spoke_number
  name                      = "r1-peer-spoke-${count.index + 1}-to-on-prem"
  resource_group_name       = local.r1_resource_group_name == null ? azurerm_resource_group.r1_rg[0].name : local.r1_resource_group_name
  virtual_network_name      = module.r1_hub_on_prem_vnet.vnet["name"]
  remote_virtual_network_id = module.r1_spoke_vnet[count.index].vnet["id"]
  allow_forwarded_traffic   = true
}
#--------------------------------------------------------------------------------
# Create VNets peering between HUBs (region 2 to region 3)
# - HUB to HUB
#--------------------------------------------------------------------------------
// VNet peering to HUB to HUB
resource "azurerm_virtual_network_peering" "r2-to-r3-peer-hub-to-hub-1" {
  depends_on                = [module.r2_hub_azure_core_vnet, module.r3_hub_azure_core_vnet]
  name                      = "r2-to-r3-peer-hub-to-hub"
  resource_group_name       = local.r2_resource_group_name == null ? azurerm_resource_group.r2_rg[0].name : local.r2_resource_group_name
  virtual_network_name      = module.r2_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r3_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}
resource "azurerm_virtual_network_peering" "r2-to-r3-peer-hub-to-hub-2" {
  depends_on                = [module.r2_hub_azure_core_vnet, module.r3_hub_azure_core_vnet]
  name                      = "r2-to-r3-peer-hub-to-hub"
  resource_group_name       = local.r3_resource_group_name == null ? azurerm_resource_group.r3_rg[0].name : local.r3_resource_group_name
  virtual_network_name      = module.r3_hub_azure_core_vnet.vnet["name"]
  remote_virtual_network_id = module.r2_hub_azure_core_vnet.vnet["id"]
  allow_forwarded_traffic   = true
}