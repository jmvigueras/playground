output "active-fgt_id" {
  value = aws_instance.active-fgt.id
}

output "passive-fgt_id" {
  value = aws_instance.passive-fgt.id
}

output "eip-active-mgmt" {
  value = aws_eip.eip-active-mgmt.public_ip
}

output "eip-passive-mgmt" {
  value = aws_eip.eip-passive-mgmt.public_ip
}

output "eip-cluster-public-ip" {
  value = aws_eip.eip-cluster-public
}

output "api_key" {
  value = random_string.api_key.result
}