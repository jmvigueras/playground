########################################################
# Create DNS Private Zone 
########################################################
# Create a Private DNS Zone
resource "azurerm_private_dns_zone" "zone-dns_sql" {
  name = "${var.prefix}.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link the Private DNS Zone with the VNET spoke-1
resource "azurerm_private_dns_zone_virtual_network_link" "spoke-1-zone-dns_sql-link" {
  name = "${var.prefix}-zone-dns-sql-vnet-spoke-1"
  resource_group_name = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.zone-dns_sql.name
  virtual_network_id = module.vnet-spoke.vnet_ids["spoke-1"]
}

# Link the Private DNS Zone with the VNET spoke-2
resource "azurerm_private_dns_zone_virtual_network_link" "spoke-2-zone-dns_sql-link" {
  name = "${var.prefix}-zone-dns-sql-vnet-spoke-2"
  resource_group_name = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.zone-dns_sql.name
  virtual_network_id = module.vnet-spoke.vnet_ids["spoke-2"]
}

########################################################
# Create DNS Record 
########################################################

# Create a DB Private DNS A Record
resource "azurerm_private_dns_a_record" "sql-dns-a_spoke-1_zone-dns_sql" {
  name = "${lower(azurerm_mssql_server.sql-server.name)}.ep-spoke-1"
  zone_name = azurerm_private_dns_zone.zone-dns_sql.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl = 300
  records = [data.azurerm_private_endpoint_connection.spoke-1-db-endpoint-cx.private_service_connection.0.private_ip_address]
}

# Create a DB Private DNS A Record
resource "azurerm_private_dns_a_record" "sql-dns-a_spoke-2_zone-dns_sql" {
  name = "${lower(azurerm_mssql_server.sql-server.name)}.ep-spoke-2"
  zone_name = azurerm_private_dns_zone.zone-dns_sql.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl = 300
  records = [data.azurerm_private_endpoint_connection.spoke-2-db-endpoint-cx.private_service_connection.0.private_ip_address]
}