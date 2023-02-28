output "fgt-spoke" {
  value = {
    site_id        = var.site["id"]
    admin          = var.adminusername
    pass           = var.adminpassword
    api_key        = random_string.api_key.result
    fgt-active_id  = azurerm_virtual_machine.fgt-active.*.id
    fgt-passive_id = azurerm_virtual_machine.fgt-passive.*.id
  }
}