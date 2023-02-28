########################################################
# Create SQL Server and DB
########################################################

resource "azurerm_mssql_server" "sql-server" {
  name                          = "${var.prefix}-sql"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.adminusername
  administrator_login_password  = var.adminpassword
  public_network_access_enabled = false

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_mssql_database" "sql-server-db" {
  name                = "${var.prefix}-sql-db"
  server_id           = azurerm_mssql_server.sql-server.id
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  license_type        = "LicenseIncluded"
  sku_name            = "Basic"
  zone_redundant      = false
  read_scale          = false
  max_size_gb         = "1"

  tags = {
    environment = var.tag_env
  }
}

########################################################
# Create Endpoint
########################################################

# Create a DB Private Endpoint spoke-1
resource "azurerm_private_endpoint" "spoke-1-db-endpoint" {
  name = "${var.prefix}-spoke-1-sql-endpoint"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = module.vnet-spoke.subnet_ids["spoke-1_pl"] 
  
  private_service_connection {
    name = "${var.prefix}-spoke-1-sql-endpoint"
    is_manual_connection = "false"
    private_connection_resource_id = azurerm_mssql_server.sql-server.id
    subresource_names = ["sqlServer"]
  }
}

# Create a DB Private Endpoint spoke-2
resource "azurerm_private_endpoint" "spoke-2-db-endpoint" {
  name = "${var.prefix}-spoke-2-sql-endpoint"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = module.vnet-spoke.subnet_ids["spoke-2_pl"] 
  
  private_service_connection {
    name = "${var.prefix}-spoke-2-sql-endpoint"
    is_manual_connection = "false"
    private_connection_resource_id = azurerm_mssql_server.sql-server.id
    subresource_names = ["sqlServer"]
  }
}

# DB Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "spoke-1-db-endpoint-cx" {
  name = azurerm_private_endpoint.spoke-1-db-endpoint.name
  resource_group_name = azurerm_resource_group.rg.name
}

# DB Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "spoke-2-db-endpoint-cx" {
  name = azurerm_private_endpoint.spoke-2-db-endpoint.name
  resource_group_name = azurerm_resource_group.rg.name
}