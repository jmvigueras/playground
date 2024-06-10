output "ilb_private-ip" {
  value = azurerm_lb.ilb.private_ip_address
}

output "elb_public-ip" {
  value = azurerm_public_ip.elb_pip.ip_address
}
