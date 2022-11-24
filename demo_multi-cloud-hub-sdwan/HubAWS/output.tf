# Output
output "FGT_Active_MGMT_Public_URL" {
  value       = "https://${module.fgt-ha.eip-active-mgmt}:${var.admin_port}"
  description = "Public URL address for the Active FortiGate's MGMT interface"
}

output "FGT_Passive_MGMT_Public_URL" {
  value       = "https://${module.fgt-ha.eip-passive-mgmt}:${var.admin_port}"
  description = "Public URL address for the Passive FortiGate's MGMT interface"
}

output "Cluster_Public_IP_advpn" {
  value       = module.fgt-ha.eip-cluster-public-ip.public_ip
  description = "Public IP for ADVPN"
}

output "FGT_Username" {
  value       = "admin"
  description = "Default Username for FortiGate Cluster"
}

output "Active-FGT_Password" {
  value       = module.fgt-ha.active-fgt_id
  description = "Default Password for FortiGate Active"
}

output "Passive-FGT_Password" {
  value       = module.fgt-ha.passive-fgt_id
  description = "Default Password for FortiGate Passive"
}

output "TestVM_spoke-1-IP" {
  value       = aws_instance.instance-spoke-1.private_ip
  description = "IP vm test spoke1"
}

output "TestVM_spoke-2-IP" {
  value       = aws_instance.instance-spoke-2.private_ip
  description = "IP vm test spoke1"
}

output "advpn_ipsec-psk-key" {
  value = random_string.advpn-ipsec-psk.result
}

output "api_key" {
  value = module.fgt-ha.api_key
}