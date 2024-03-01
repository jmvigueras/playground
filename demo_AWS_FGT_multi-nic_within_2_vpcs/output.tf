#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fgt_ids" {
  value = module.fgt.fgt_list
}

output "fgt_ni_list" {
  value = module.fgt_nis.fgt_ni_list
}

output "spoke_vpc_vm" {
  value = { for k, v in module.spoke_vpc_vm : k => v.vm }
}

#-----------------------------------------------------------------------------------------------------
# Debug
/* 
output "fgt_ports_config" {
  value = local.fgt_ports_config
}
*/