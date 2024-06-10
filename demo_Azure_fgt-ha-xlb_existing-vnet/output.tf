output "fgt" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    api_key      = module.fgt_config.api_key
    active_mgmt  = "https://${module.fgt_vnet.fgt-1-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.fgt_vnet.fgt-2-mgmt-ip}:${local.admin_port}"
  }
}

