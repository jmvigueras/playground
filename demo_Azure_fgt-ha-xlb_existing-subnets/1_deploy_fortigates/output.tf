output "fgt" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    active_mgmt  = "https://${module.fgt_nis.fgt-1-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.fgt_nis.fgt-2-mgmt-ip}:${local.admin_port}"
  }
}

