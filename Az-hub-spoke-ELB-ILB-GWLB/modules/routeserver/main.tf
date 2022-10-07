resource "azurerm_public_ip" "public-ip-rs" {
  name                = "${var.prefix}-rs-${var.vnet_name}-pip"
  resource_group_name = var.resourcegroup_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_route_server" "rs" {
  name                             = "${var.prefix}-rs-${var.vnet_name}"
  resource_group_name              = var.resourcegroup_name
  location                         = var.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.public-ip-rs.id
  subnet_id                        = var.subnet_id
}

resource "azurerm_route_server_bgp_connection" "rs-spokec-bgp-fgt-active" {
  name            = "${var.prefix}-bgp-fgt-active"
  route_server_id = azurerm_route_server.rs.id
  peer_asn        = var.fgt_bgp-asn
  peer_ip         = var.fgt1_peer-ip
}

resource "azurerm_route_server_bgp_connection" "rs-spokec-bgp-fgt-passive" {
  name            = "${var.prefix}-bgp-fgt-passive"
  route_server_id = azurerm_route_server.rs.id
  peer_asn        = var.fgt_bgp-asn
  peer_ip         = var.fgt2_peer-ip
}