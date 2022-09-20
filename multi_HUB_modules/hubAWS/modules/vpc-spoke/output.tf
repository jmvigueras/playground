output "vpc-spoke_ids" {
  value = {
    "vpc-spoke-1"    = aws_vpc.vpc-spoke-1.id
    "vpc-spoke-2"    = aws_vpc.vpc-spoke-2.id
  }
}

output "subnet-vpc-spoke" {
  value = {
    "spoke-1-vm_net"    = aws_subnet.subnet-vpc-spoke-1-vm.cidr_block
    "spoke-2-vm_net"    = aws_subnet.subnet-vpc-spoke-2-vm.cidr_block
    "spoke-1-vm_id"    = aws_subnet.subnet-vpc-spoke-1-vm.id
    "spoke-2-vm_id"    = aws_subnet.subnet-vpc-spoke-2-vm.id
  }
}

output "ni-vm-spoke_ids" {
  value = {
    "spoke-1-vm"    = aws_network_interface.ni-vm-spoke-1.id
    "spoke-2-vm"    = aws_network_interface.ni-vm-spoke-2.id
  }
}

output "tgw-att-vpc-spoke-1_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-spoke-1.id
}

output "tgw-att-vpc-spoke-2_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-spoke-2.id
}