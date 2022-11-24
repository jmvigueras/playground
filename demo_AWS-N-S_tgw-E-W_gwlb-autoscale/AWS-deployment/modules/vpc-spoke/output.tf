output "ni-spoke-vm_id" {
  value = {
    "spoke-1_id" = aws_network_interface.ni-vm-spoke-1.id
    "spoke-2_id" = aws_network_interface.ni-vm-spoke-2.id
  }
}

output "ni-spoke-vm_ip" {
  value = {
    "spoke-1_ip" = aws_network_interface.ni-vm-spoke-1.private_ip
    "spoke-2_ip" = aws_network_interface.ni-vm-spoke-2.private_ip
  }
}

output "subnet-spoke-vm" {
  value = {
    "spoke-1-vm_net"  = aws_subnet.subnet-vpc-spoke-1-vm.cidr_block
    "spoke-2-vm_net"  = aws_subnet.subnet-vpc-spoke-2-vm.cidr_block
    "spoke-1-vm_id"   = aws_subnet.subnet-vpc-spoke-1-vm.id
    "spoke-2-vm_id"   = aws_subnet.subnet-vpc-spoke-2-vm.id
    "spoke-1-gwlb_id" = aws_subnet.subnet-vpc-spoke-1-gwlb.id
    "spoke-2-gwlb_id" = aws_subnet.subnet-vpc-spoke-2-gwlb.id
    "spoke-1-tgw_id"  = aws_subnet.subnet-vpc-spoke-1-tgw.id
    "spoke-2-tgw_id"  = aws_subnet.subnet-vpc-spoke-2-tgw.id
  }
}

output "vpc-spokes_id" {
  value = {
    "vpc-spoke-1_id" = aws_vpc.vpc-spoke-1.id
    "vpc-spoke-2_id" = aws_vpc.vpc-spoke-2.id
  }
}

output "tgw-att-vpc-spoke-1_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-spoke-1.id
}

output "tgw-att-vpc-spoke-2_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-spoke-2.id
}