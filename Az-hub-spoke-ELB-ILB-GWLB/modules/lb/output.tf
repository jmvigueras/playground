output "ilb_private-ip"{
  value = azurerm_lb.ilb.private_ip_address
}

output "elb_public-ip"{
  value = azurerm_public_ip.elb-pip.ip_address
}

output "gwlb_frontip_config_id"{
  value = azurerm_lb.gwlb.frontend_ip_configuration
}

