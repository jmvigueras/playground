output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value = var.admin_password
}

output "fgt-1_id" {
  value = azurerm_virtual_machine.fgt-1.id
}

output "fgt-2_id" {
  value = azurerm_virtual_machine.fgt-2.*.id
}