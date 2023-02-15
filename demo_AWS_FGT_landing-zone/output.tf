# Output
output "fgt" {
  value = {
    fgt-1_mgmt = "https://${module.fgt.fgt_active_eip_public}:${local.admin_port}"
    fgt-2_mgmt = module.fgt.fgt_passive_eip_public
    username   = "admin"
    fgt-1_pass = module.fgt.fgt_active_id
    fgt-2_pass = module.fgt.fgt_passive_id
    admin_cidr = local.admin_cidr
    api_key    = module.fgt_config.api_key
  }
}