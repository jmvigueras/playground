resource "azurerm_public_ip" "elb-pip" {
  name                = "${var.prefix}-elb-pip"
  location            = var.location
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.prefix), "elb-pip")
}

resource "azurerm_lb" "elb" {
  name                = "${var.prefix}-ExternalLoadBalancer"
  location            = var.location
  resource_group_name = var.resourcegroup_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}-elb-front-pip"
    public_ip_address_id = azurerm_public_ip.elb-pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "elbbackend" {
  loadbalancer_id     = azurerm_lb.elb.id
  name                = "BackEndPool"
}

resource "azurerm_lb_probe" "elbprobe" {
  loadbalancer_id     = azurerm_lb.elb.id
  name                = "lbprobe"
  port                = var.backend-probe_port
  interval_in_seconds = 5
  number_of_probes = 2
  protocol = "Tcp"
}

resource "azurerm_lb_rule" "lbrule-tcp80" {
    loadbalancer_id                = azurerm_lb.elb.id
    name                           = "PublicLBRule-FE1-http"
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "${var.prefix}-elb-front-pip"
    probe_id                       = azurerm_lb_probe.elbprobe.id
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elbbackend.id]
}
  
resource "azurerm_lb_rule" "lbrule-upd500" {
    loadbalancer_id                = azurerm_lb.elb.id
    name                           = "PublicLBRule-FE1-udp500"
    protocol                       = "Udp"
    frontend_port                  = 500
    backend_port                   = 500
    frontend_ip_configuration_name = "${var.prefix}-elb-front-pip"
    probe_id                       = azurerm_lb_probe.elbprobe.id
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elbbackend.id]
}

resource "azurerm_lb_rule" "lbrule-udp4500" {
    loadbalancer_id                = azurerm_lb.elb.id
    name                           = "PublicLBRule-FE1-udp4500"
    protocol                       = "Udp"
    frontend_port                  = 4500
    backend_port                   = 4500
    frontend_ip_configuration_name = "${var.prefix}-elb-front-pip"
    probe_id                       = azurerm_lb_probe.elbprobe.id
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elbbackend.id]
}

resource "azurerm_network_interface_backend_address_pool_association" "fgt1-elb-backendpool" {
  network_interface_id    = var.fgt-ni_ids["fgt1-public"]
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "fgt2-elb-backendpool" {
  network_interface_id    = var.fgt-ni_ids["fgt2-public"]
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend.id
}