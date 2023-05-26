output "fgt" {
  value = {
    fgt-1_mgmt   = "https://${module.fgt.fgt_active_eip_mgmt}:${local.admin_port}"
    fgt-1_pass   = module.fgt.fgt_active_id
    fgt-2_mgmt   = join(":",[for ip in module.fgt.fgt_passive_eip_mgmt : ip],[local.admin_port])
    fgt-2_pass   = join(",",[for id in module.fgt.fgt_passive_id : id])
    fgt-1_public = module.fgt.fgt_active_eip_public
    api_key      = module.fgt_config.api_key
  }
}

output "vm_spoke_zone1" {
  value = {
    admin_user = split("@", data.google_client_openid_userinfo.me.email)[0]
    pip        = join(", ",[for vm in module.vm_spoke_zone1 : vm.vm["pip"]])
    ip         = join(", ",[for vm in module.vm_spoke_zone1 : vm.vm["ip"]])
  }
}

output "vm_spoke_zone2" {
  value = {
    admin_user = split("@", data.google_client_openid_userinfo.me.email)[0]
    pip        = join(", ",[for vm in module.vm_spoke_zone2 : vm.vm["pip"]])
    ip         = join(", ",[for vm in module.vm_spoke_zone2 : vm.vm["ip"]])
  }
}