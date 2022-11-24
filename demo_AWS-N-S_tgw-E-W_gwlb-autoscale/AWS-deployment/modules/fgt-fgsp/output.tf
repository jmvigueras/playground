output "id" {
  value = aws_instance.fgt.id
}

output "eip" {
  value = aws_eip.fgt_eip-port2.public_ip
}