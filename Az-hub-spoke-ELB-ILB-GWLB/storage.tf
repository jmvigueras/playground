resource "random_id" "randomId" {
  byte_length = 8
}

resource "azurerm_storage_account" "fgtstorageaccount" {
  name                     = "stgra${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"

  tags = {
    environment = var.tag_env
  }
}