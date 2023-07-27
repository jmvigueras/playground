output "fgt_hub_azure" {
  value = {
    admin        = local.admin_username
    pass         = local.admin_password
    fgt_1_mgmt   = "https://${module.fgt_hub_vnet.fgt-active-mgmt-ip}:${local.admin_port}"
    fgt_2_mgmt   = "https://${module.fgt_hub_vnet.fgt-passive-mgmt-ip}:${local.admin_port}"
  }
}
output "fgt_spoke_oci" {
  value = {
    fgt_1_id    = module.fgt.fgt_1_id
    fgt_2_id    = module.fgt.fgt_2_id
    fgt_1_mgmt  = "https://${module.fgt.fgt_1_public_ip_mgmt}:${local.admin_port}"
    fgt_2_mgmt  = "https://${module.fgt.fgt_2_public_ip_mgmt}:${local.admin_port}"
  }
}
output "vm_bastion_hub" {
  value = module.vm_bastion_oci.vm
}
output "vm_bastion_spoke" {
  value = module.vm_bastion_azure.vm
}