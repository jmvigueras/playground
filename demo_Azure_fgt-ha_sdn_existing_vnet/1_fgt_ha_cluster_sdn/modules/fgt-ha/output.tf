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
  value = join("", [for fgt-2 in azurerm_virtual_machine.fgt-2 : fgt-2.id])
}

output "fgt-1_principal_id" {
  value = azurerm_virtual_machine.fgt-1.identity[0].principal_id
}

output "fgt-2_principal_id" {
  value = join("", [for fgt-2 in azurerm_virtual_machine.fgt-2 : fgt-2.identity[0].principal_id])
}