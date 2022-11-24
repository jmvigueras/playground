output "HUB-FGTCluster" {
  value = {
    admin           = var.adminusername
    pass            = var.adminpassword
    api_key         = module.fgt-ha.api_key
    active_mgmt     = "https://${module.vnet-fgt.fgt-active-mgmt-ip}:${var.admin_port}"
    passive_mgmt    = "https://${module.vnet-fgt.fgt-passive-mgmt-ip}:${var.admin_port}"
    advpn-ipsec-psk = module.fgt-ha.advpn-ipsec-psk
  }
}