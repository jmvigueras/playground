#------------------------------------------------------------------------
# Create External LB
#------------------------------------------------------------------------
// Create frontend public ip
resource "azurerm_public_ip" "elb_pip" {
  name                = "${var.prefix}-elb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.prefix), "elb-pip")
}
// Create load balacner
resource "azurerm_lb" "elb" {
  name                = "${var.prefix}-elb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "${var.prefix}-elb-frontend"
    public_ip_address_id = azurerm_public_ip.elb_pip.id
  }
}
// Create health check
resource "azurerm_lb_probe" "elb_probe" {
  loadbalancer_id     = azurerm_lb.elb.id
  name                = "lbprobe"
  port                = var.backend-probe_port
  interval_in_seconds = 5
  number_of_probes    = 2
  protocol            = "Tcp"
}
// Create address pool
resource "azurerm_lb_backend_address_pool" "elb_backend" {
  loadbalancer_id = azurerm_lb.elb.id
  name            = "BackEndPool"
}
// Create BackEnd Pools associate to Fortigate IPs
resource "azurerm_lb_backend_address_pool_address" "elb_backend_fgt_1" {
  name                    = "BackEndPool-fgt-1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend.id
  virtual_network_id      = var.vnet-fgt["id"]
  ip_address              = var.fgt-active-ni_ips["public"]
}
resource "azurerm_lb_backend_address_pool_address" "elb_backend_fgt_2" {
  name                    = "BackEndPool-fgt-2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend.id
  virtual_network_id      = var.vnet-fgt["id"]
  ip_address              = var.fgt-passive-ni_ips["public"]
}
// Create Load Balancing Rules
resource "azurerm_lb_rule" "elb_listeners" {
  for_each                       = var.elb_listeners
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "elb-rule-${each.key}-${lower(each.value)}"
  protocol                       = each.value
  frontend_port                  = each.key
  backend_port                   = each.key
  frontend_ip_configuration_name = "${var.prefix}-elb-frontend"
  probe_id                       = azurerm_lb_probe.elb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elb_backend.id]
  load_distribution              = "SourceIP"
  enable_floating_ip             = var.elb_floating_ip
}