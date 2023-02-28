#---------------------------------------------------------------------------------------
# Create connection VNET FGT to vWAN and dynamic routing
# - Create new connection to vWAN
# - Create BGP peer connections in vHUB
#---------------------------------------------------------------------------------------
resource "azurerm_virtual_hub_connection" "onramp_vhub_connnection_vnet-fgt" {
  name                      = "${var.prefix}-onramp-cx-vnet-fgt"
  virtual_hub_id            = var.vhub_id
  remote_virtual_network_id = module.onramp_vnet-fgt.vnet["id"]
}

//Create BGP connection to FGT active
resource "azurerm_virtual_hub_bgp_connection" "onramp_vhub_bgp_fgt-1" {
  name                          = "${var.prefix}-onramp-cx-fgt-active"
  virtual_hub_id                = var.vhub_id
  peer_asn                      = var.site_onramp["bgp-asn"]
  peer_ip                       = module.onramp_vnet-fgt.fgt-active-ni_ips["port3"]
  virtual_network_connection_id = azurerm_virtual_hub_connection.onramp_vhub_connnection_vnet-fgt.id
}
//Create BGP connection to FGT passive
resource "azurerm_virtual_hub_bgp_connection" "onramp_vhub_bgp_fgt-2" {
  name                          = "${var.prefix}-onramp-cx-fgt-passive"
  virtual_hub_id                = var.vhub_id
  peer_asn                      = var.site_onramp["bgp-asn"]
  peer_ip                       = module.onramp_vnet-fgt.fgt-passive-ni_ips["port3"]
  virtual_network_connection_id = azurerm_virtual_hub_connection.onramp_vhub_connnection_vnet-fgt.id
}
