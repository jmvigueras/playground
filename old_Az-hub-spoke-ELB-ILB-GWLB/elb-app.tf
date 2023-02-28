########################################################
# Create ELB app spoke-1
########################################################
resource "azurerm_public_ip" "elb-app-spoke-1-pip" {
  name                = "${var.prefix}-elb-app-spoke-1-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.prefix), "elb-app-spoke-1-pip")
}

resource "azurerm_lb" "elb-app-spoke-1" {
  name                = "${var.prefix}-elb-app-spoke-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}-elb-app-spoke-1-front-pip"
    public_ip_address_id = azurerm_public_ip.elb-app-spoke-1-pip.id
    // gateway_load_balancer_frontend_ip_configuration_id = module.lb.gwlb_frontip_config_id
  }
}

resource "azurerm_lb_backend_address_pool" "elbbackend-app-spoke-1" {
  loadbalancer_id     = azurerm_lb.elb-app-spoke-1.id
  name                = "BackEndPool"
}

resource "azurerm_lb_probe" "elbprobe-app-spoke-1" {
  loadbalancer_id     = azurerm_lb.elb-app-spoke-1.id
  name                = "lbprobe"
  port                = "80"
  interval_in_seconds = 5
  number_of_probes = 2
  protocol = "Tcp"
}

resource "azurerm_lb_rule" "lbrule-app-tcp80-spoke-1" {
    loadbalancer_id                = azurerm_lb.elb-app-spoke-1.id
    name                           = "PublicLBRule-app-http"
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "${var.prefix}-elb-app-spoke-1-front-pip"
    probe_id                       = azurerm_lb_probe.elbprobe-app-spoke-1.id
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elbbackend-app-spoke-1.id]
}

resource "azurerm_network_interface_backend_address_pool_association" "vm1-elb-app-spoke-1-backendpool" {
  network_interface_id    = module.vnet-spoke.ni_ids["spoke-1_subnet1"]
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend-app-spoke-1.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm2-elb-app-spoke-1-backendpool" {
  network_interface_id    = module.vnet-spoke.ni_ids["spoke-1_subnet2"]
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend-app-spoke-1.id
}

/*
########################################################
# Create ELB app spoke-2
########################################################
resource "azurerm_public_ip" "elb-app-spoke-2-pip" {
  name                = "${var.prefix}-elb-app-spoke-2-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.prefix), "elb-app-spoke-2-pip")
}

resource "azurerm_lb" "elb-app-spoke-2" {
  name                = "${var.prefix}-elb-app-spoke-2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}-elb-app-spoke-2-front-pip"
    public_ip_address_id = azurerm_public_ip.elb-app-spoke-2-pip.id
    gateway_load_balancer_frontend_ip_configuration_id = module.lb.gwlb_frontip_config_id
  }
}

resource "azurerm_lb_backend_address_pool" "elbbackend-app-spoke-2" {
  loadbalancer_id     = azurerm_lb.elb-app-spoke-2.id
  name                = "BackEndPool"
}

resource "azurerm_lb_probe" "elbprobe-app-spoke-2" {
  loadbalancer_id     = azurerm_lb.elb-app-spoke-2.id
  name                = "lbprobe"
  port                = "80"
  interval_in_seconds = 5
  number_of_probes = 2
  protocol = "Tcp"
}

resource "azurerm_lb_rule" "lbrule-app-tcp80-spoke-2" {
    loadbalancer_id                = azurerm_lb.elb-app-spoke-2.id
    name                           = "PublicLBRule-app-http"
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "${var.prefix}-elb-app-spoke-2-front-pip"
    probe_id                       = azurerm_lb_probe.elbprobe-app-spoke-2.id
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elbbackend-app-spoke-2.id]
}

resource "azurerm_network_interface_backend_address_pool_association" "vm1-elb-app-spoke-2-backendpool" {
  network_interface_id    = module.vnet-spoke.ni_ids["spoke-2_subnet1"]
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend-app-spoke-2.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm2-elb-app-spoke-2-backendpool" {
  network_interface_id    = module.vnet-spoke.ni_ids["spoke-2_subnet2"]
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend-app-spoke-2.id
}
*/