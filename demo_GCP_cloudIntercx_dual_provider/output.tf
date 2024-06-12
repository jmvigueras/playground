output "cloud" {
  value = {
    fgt-1_mgmt   = "https://${module.cloud.fgt_active_eip_mgmt}:${local.admin_port}"
    fgt-1_pass   = module.cloud.fgt_active_id
    fgt-2_mgmt   = module.cloud.fgt_passive_eip_mgmt
    fgt-2_pass   = module.cloud.fgt_passive_id
    fgt-1_public = module.cloud.fgt_active_eip_public
  }
}

output "cloud_vpn1" {
  value = {
    fgt-1_mgmt = "https://${module.cloud_vpn1.fgt_eip_public}:${local.admin_port}"
    fgt-1_pass = module.cloud_vpn1.fgt_id
  }
}

output "cloud_peer_vm" {
  value = {
    admin_user = split("@", data.google_client_openid_userinfo.me.email)[0]
    pip        = [for i, k in module.cloud_peer_vm : k.vm["pip"]]
    ip         = [for i, k in module.cloud_peer_vm : k.vm["ip"]]
  }
}

output "onprem" {
  value = {
    fgt-1_mgmt = "https://${module.onprem.fgt_eip_public}:${local.admin_port}"
    fgt-1_pass = module.onprem.fgt_id
  }
}

output "onprem_vpn1" {
  value = {
    fgt-1_mgmt = "https://${module.onprem_vpn1.fgt_eip_public}:${local.admin_port}"
    fgt-1_pass = module.onprem_vpn1.fgt_id
  }
}

output "onprem_bastion" {
  value = {
    admin_user = split("@", data.google_client_openid_userinfo.me.email)[0]
    pip        = module.onprem_bastion.vm["pip"]
    ip         = module.onprem_bastion.vm["ip"]
  }
}