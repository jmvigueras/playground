
resource "azurerm_availability_set" "av-set-1" {
  name                = "${var.prefix}-availset-1"
  location            = var.location
  resource_group_name = var.resourcegroup_name
  managed             = true
}

resource "azurerm_lb" "gwlb" {
  name                = "${var.prefix}-GatewayLoadBalancer"
  location            = var.location
  resource_group_name = var.resourcegroup_name
  sku                 = "Gateway"
  
  frontend_ip_configuration {
    name                          = "${var.prefix}-gwlb-front-ip"
    subnet_id                     = var.subnet-private["id"]
    private_ip_address            = cidrhost(var.subnet-private["cidr"],15)
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_backend_address_pool" "gwlbbackend" {
  loadbalancer_id   = azurerm_lb.gwlb.id
  name              = "BackEndPool"

  tunnel_interface  {
    identifier = "800"
    type       = "Internal"
    protocol   = "VXLAN"
    port       = "10800"
  }
  tunnel_interface  {
    identifier = "801"
    type       = "External"
    protocol   = "VXLAN"
    port       = "10801"
  }
}
  
resource "azurerm_lb_probe" "gwlbprobe" {
  loadbalancer_id = azurerm_lb.gwlb.id
  name            = "lbprobe"
  port            = var.backend-probe_port
  interval_in_seconds = 5
  number_of_probes = 2
  protocol = "Tcp"
}

resource "azurerm_lb_rule" "gwlb_haports_rule" {
  loadbalancer_id                = azurerm_lb.gwlb.id
  name                           = "gwlb_haports_rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "${var.prefix}-gwlb-front-ip"
  probe_id                       = azurerm_lb_probe.gwlbprobe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.gwlbbackend.id]
}

resource "azurerm_network_interface_backend_address_pool_association" "fgt1-gwlb-backendpool" {
  network_interface_id    = var.fgt-ni_ids["fgt1-private"]
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gwlbbackend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "fgt2-gwlb-backendpool" {
  network_interface_id    = var.fgt-ni_ids["fgt2-private"]
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gwlbbackend.id
}