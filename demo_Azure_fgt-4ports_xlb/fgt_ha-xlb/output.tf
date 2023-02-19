output "fgt" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    api_key      = module.fgt_config.api_key
    active_mgmt  = "https://${module.fgt_ni-nsg.fgt-active-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.fgt_ni-nsg.fgt-passive-mgmt-ip}:${local.admin_port}"
  }
}

