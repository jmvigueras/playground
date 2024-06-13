output "vm_username" {
  value = var.admin_username
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "vm" {
  value = {
    vm_name      = azurerm_linux_virtual_machine.vm.name
    username     = var.admin_username
    private_ip   = var.ni_ip == null ? cidrhost(var.subnet_cidr, 10) : var.ni_ip
    public_ip    = azurerm_public_ip.vm_ni_pip.ip_address
  }
}