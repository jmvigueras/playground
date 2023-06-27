#------------------------------------------------------------------------
# Create Gateway LB
#------------------------------------------------------------------------
resource "azurerm_lb" "gwlb" {
  count               = var.config_gwlb ? 1 : 0
  name                = "${var.prefix}-GatewayLoadBalancer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Gateway"

  frontend_ip_configuration {
    name                          = "gwlb-front-ip"
    subnet_id                     = var.subnet_ids["private"]
    private_ip_address            = var.gwlb_ip != null ? var.gwlb_ip : cidrhost(var.subnet_cidrs["private"], 8)
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_backend_address_pool" "gwlb_backend" {
  count           = var.config_gwlb ? 1 : 0
  loadbalancer_id = azurerm_lb.gwlb[0].id
  name            = "BackEndPool"

  tunnel_interface {
    identifier = var.gwlb_vxlan["vdi_int"]
    type       = "Internal"
    protocol   = "VXLAN"
    port       = var.gwlb_vxlan["port_int"]
  }
  tunnel_interface {
    identifier = var.gwlb_vxlan["vdi_ext"]
    type       = "External"
    protocol   = "VXLAN"
    port       = var.gwlb_vxlan["port_ext"]
  }
}

resource "azurerm_lb_backend_address_pool_address" "gwlb_backend_fgt_1" {
  count                   = var.config_gwlb ? 1 : 0
  name                    = "BackEndPool-fgt-1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gwlb_backend[0].id
  virtual_network_id      = var.vnet-fgt["id"]
  ip_address              = var.fgt-active-ni_ips["private"]
}

resource "azurerm_lb_backend_address_pool_address" "gwlb_backend_fgt_2" {
  count                   = var.config_gwlb ? 1 : 0
  name                    = "BackEndPool-fgt-2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gwlb_backend[0].id
  virtual_network_id      = var.vnet-fgt["id"]
  ip_address              = var.fgt-passive-ni_ips["private"]
}

resource "azurerm_lb_probe" "gwlb_probe" {
  count               = var.config_gwlb ? 1 : 0
  loadbalancer_id     = azurerm_lb.gwlb[0].id
  name                = "lbprobe"
  port                = var.backend-probe_port
  interval_in_seconds = 5
  number_of_probes    = 2
  protocol            = "Tcp"
}

resource "azurerm_lb_rule" "gwlb_rule_haport" {
  count                          = var.config_gwlb ? 1 : 0
  loadbalancer_id                = azurerm_lb.gwlb[0].id
  name                           = "gwlb-rule-haport"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "gwlb-front-ip"
  probe_id                       = azurerm_lb_probe.gwlb_probe[0].id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.gwlb_backend[0].id]
}


