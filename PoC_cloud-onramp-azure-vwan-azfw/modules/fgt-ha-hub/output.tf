output "hub" {
  value = {
    id         = var.hub["id"]
    bgp-asn    = var.hub["bgp-asn"]
    hub-ip     = cidrhost(var.hub["advpn-net"], 1)
    site-ip    = cidrhost(var.hub["advpn-net"], 10)
    advpn-net  = var.hub["advpn-net"]
    hck-srv-ip = cidrhost(var.hub["advpn-net"], 1)
    advpn-psk  = random_string.advpn-ipsec-psk.result
    cidr       = var.hub["cidr"]
  }
}

output "fgt" {
  value = {
    admin          = var.adminusername
    pass           = var.adminpassword
    api_key        = random_string.api_key.result
    fgt-active_id  = azurerm_virtual_machine.fgt-active.*.id
    fgt-passive_id = azurerm_virtual_machine.fgt-passive.*.id
  }
}