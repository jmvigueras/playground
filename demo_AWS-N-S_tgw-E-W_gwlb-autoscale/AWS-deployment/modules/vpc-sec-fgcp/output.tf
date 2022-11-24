output "eni-active" {
  value = {
    "port1_id" = aws_network_interface.ni-active-port1.id
    "port2_id" = aws_network_interface.ni-active-port2.id
    "port3_id" = aws_network_interface.ni-active-port3.id
    "port1_ip" = aws_network_interface.ni-active-port1.private_ip
    "port2_ip" = aws_network_interface.ni-active-port2.private_ip
    "port3_ip" = aws_network_interface.ni-active-port3.private_ip
  }
}

output "eni-passive" {
  value = {
    "port1_id" = aws_network_interface.ni-passive-port1.id
    "port2_id" = aws_network_interface.ni-passive-port2.id
    "port3_id" = aws_network_interface.ni-passive-port3.id
    "port1_ip" = aws_network_interface.ni-passive-port1.private_ip
    "port2_ip" = aws_network_interface.ni-passive-port2.private_ip
    "port3_ip" = aws_network_interface.ni-passive-port3.private_ip
  }
}

output "subnet-az1-vpc-sec" {
  value = {
    "public_net"  = aws_subnet.subnet-az1-public.cidr_block
    "private_net" = aws_subnet.subnet-az1-private.cidr_block
    "mgmt-ha_net" = aws_subnet.subnet-az1-mgmt-ha.cidr_block
    "tgw_net"     = aws_subnet.subnet-az1-tgw.cidr_block
    "gwlb_net"    = aws_subnet.subnet-az1-gwlb.cidr_block
  }
}

output "subnet-az2-vpc-sec" {
  value = {
    "public_net"  = aws_subnet.subnet-az2-public.cidr_block
    "private_net" = aws_subnet.subnet-az2-private.cidr_block
    "mgmt-ha_net" = aws_subnet.subnet-az2-mgmt-ha.cidr_block
    "tgw_net"     = aws_subnet.subnet-az2-tgw.cidr_block
    "gwlb_net"    = aws_subnet.subnet-az2-gwlb.cidr_block
  }
}

output "tgw-att-vpc-sec_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-sec.id
}