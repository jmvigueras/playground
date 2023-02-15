output "fgt_active_id" {
  value = aws_instance.fgt_active.id
}

output "fgt_passive_id" {
  value = aws_instance.fgt_passive.*.id
}
/*
output "fgt_active_eip_mgmt" {
  value = aws_eip.fgt_active_eip_mgmt.public_ip
}

output "fgt_passive_eip_mgmt" {
  value = aws_eip.fgt_passive_eip_mgmt.public_ip
}
*/
output "fgt_active_eip_public" {
  value = aws_eip.fgt_active_eip_public.public_ip
}

output "fgt_passive_eip_public" {
  value = aws_eip.fgt_passive_eip_public.*.public_ip
}