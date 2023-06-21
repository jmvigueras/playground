output "fgt" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    active_mgmt  = "https://${module.fgt_ni-nsg.fgt-active-mgmt-ip}:${local.admin_port}"
    passive_mgmt = "https://${module.fgt_ni-nsg.fgt-passive-mgmt-ip}:${local.admin_port}"
  }
}

/*
output "vm_test" {
  value = module.vm_test.*.vm
}
*/