# Output
output "fgt-fgsp_master" {
  value = {
    mgmt-url   = "https://${module.fgt-fgsp.eip}:${var.admin-sport}"
    username   = "admin"
    password   = module.fgt-fgsp.id
    admin_cidr = "${chomp(data.http.my-public-ip.body)}/32"
    api_key    = random_string.api_key.result
  }
}

output "fgt-fgcp_master" {
  value = {
    mgmt-url   = "https://${module.fgt-ha.eip-active-mgmt}:${var.admin-sport}"
    username   = "admin"
    password   = module.fgt-ha.active-fgt_id
    advpn_psk  = var.advpn-ipsec-psk
    advpn_pip  = module.fgt-ha.eip-cluster-public-ip
    admin_cidr = "${chomp(data.http.my-public-ip.body)}/32"
    api_key    = random_string.api_key.result
  }
}

output "vm_ip_spoke-1" {
  description = "VM test spoke1"
  value = {
    private_ip = aws_instance.instance-spoke-1.private_ip
    public_ip  = "ubuntu@${aws_eip.eip-vpc-spoke-1-vm.public_ip}"
    admin_cidr = "${chomp(data.http.my-public-ip.body)}/32"
  }
}

output "vm_ip_spoke-2" {
  description = "VM test spoke2"
  value = {
    private_ip = aws_instance.instance-spoke-2.private_ip
    public_ip  = "ubuntu@${aws_eip.eip-vpc-spoke-2-vm.public_ip}"
    admin_cidr = "${chomp(data.http.my-public-ip.body)}/32"
  }
}

output "gwlb_ips" {
  value = {
    ip1 = data.aws_network_interface.gwlb_ni-az1.private_ip
    ip2 = data.aws_network_interface.gwlb_ni-az2.private_ip
  }
}