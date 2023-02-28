output "hub-fgt-mgmt-url" {
  value = {
    fgt-active  = "https://${module.vnet-fgt.fgt-active-mgmt-ip}:${var.admin_port}"
    fgt-passive = "https://${module.vnet-fgt.fgt-passive-mgmt-ip}:${var.admin_port}"
    Username    = var.adminusername
    Password    = var.adminpassword
    api_key     = module.fgt-ha.api_key
  }
}

output "site-fgt-mgmt-url" {
  value = {
    fgt-site-1  = "https://${module.site1.fgt-site-mgmt-ip}:${var.admin_port}"
  }
}

output "hub-fgt-bgp" {
  value = {
    fgt-active  = module.vnet-fgt.fgt-active-ni_ips["port3"]
    fgt-passive = module.vnet-fgt.fgt-passive-ni_ips["port3"]
    rs_spoke-1  = "${tolist(module.rs-spoke-1.rs_ips)[0]}, ${tolist(module.rs-spoke-1.rs_ips)[1]}"
    rs_spoke-2  = "${tolist(module.rs-spoke-2.rs_ips)[0]}, ${tolist(module.rs-spoke-2.rs_ips)[1]}"
  }
}

output "hub1-advpn-psk-key" {
  value = {
    advpn_ipsec-psk-key = random_id.advpn-psk-key.hex
  }
}

output "public-ips" {
  value = {
     cluster-public-ip_ip    = module.vnet-fgt.cluster-public-ip_ip
     elb_public-ip           = module.lb.elb_public-ip
     elb-app-spoke-1-pip     = azurerm_public_ip.elb-app-spoke-1-pip.ip_address
//     elb-app-spoke-2-pip     = azurerm_public_ip.elb-app-spoke-2-pip.ip_address
  }
}

output "private-ips" {
  value = {
    ilb_private-ip = module.lb.ilb_private-ip
    TestVM-spoke-1-subnet1-ip = module.vnet-spoke.ni_ips["spoke-1_subnet1"]
    TestVM-spoke-1-subnet2-ip = module.vnet-spoke.ni_ips["spoke-1_subnet2"]
    TestVM-spoke-2-subnet1-ip = module.vnet-spoke.ni_ips["spoke-2_subnet1"]
    TestVM-spoke-2-subnet2-ip = module.vnet-spoke.ni_ips["spoke-2_subnet2"]
  }
}

output "sql-server_fqdns" {
  value = { 
    spoke-1 = "${lower(azurerm_mssql_server.sql-server.name)}.ep-spoke-1.${var.prefix}.database.windows.net : ${data.azurerm_private_endpoint_connection.spoke-1-db-endpoint-cx.private_service_connection.0.private_ip_address}"
    spoke-2 = "${lower(azurerm_mssql_server.sql-server.name)}.ep-spoke-2.${var.prefix}.database.windows.net : ${data.azurerm_private_endpoint_connection.spoke-2-db-endpoint-cx.private_service_connection.0.private_ip_address}"
  }
}

output "resource-group" {
  value = azurerm_resource_group.rg.name
}

output "vnet-fgt_id" {
  value = module.vnet-fgt.vnet_ids["vnet-fgt"]
}

output "private_endpoint_status" {
  value = {
     spoke-1 = data.azurerm_private_endpoint_connection.spoke-1-db-endpoint-cx.private_service_connection.0.status
     spoke-2 = data.azurerm_private_endpoint_connection.spoke-2-db-endpoint-cx.private_service_connection.0.status
  }
}