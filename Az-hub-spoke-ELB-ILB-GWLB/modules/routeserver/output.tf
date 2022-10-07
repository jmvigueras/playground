output "rs_bgp-asn"{
  value = azurerm_route_server.rs.virtual_router_asn
}

output "rs_ips"{
  value = azurerm_route_server.rs.virtual_router_ips
}