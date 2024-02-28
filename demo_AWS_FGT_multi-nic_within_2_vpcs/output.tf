#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fgt_ids" {
  value = module.fgt.fgt_list
}

output "fgt_ni_list" {
  value = module.fgt_nis.fgt_ni_list
}

output "vpc_1_vm" {
  value = module.vpc_1_vm.vm
}

output "vpc_2_vm" {
  value = module.vpc_2_vm.vm
}