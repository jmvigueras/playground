output "fgt_eni" {
  value = {
    "port1_id" = aws_network_interface.ni-port1.id
    "port2_id" = aws_network_interface.ni-port2.id
    "port1_ip" = aws_network_interface.ni-port1.private_ip
    "port2_ip" = aws_network_interface.ni-port2.private_ip
  }
}

output "subnet-az1_cidr" {
  value = {
    "private" = aws_subnet.subnet-az1-private.cidr_block
    "gwlb"    = aws_subnet.subnet-az1-gwlb.cidr_block
    "mgmt"    = aws_subnet.subnet-az1-mgmt.cidr_block
    "tgw"     = aws_subnet.subnet-az1-tgw.cidr_block
  }
}

output "subnet-az2_cidr" {
  value = {
    "private" = aws_subnet.subnet-az2-private.cidr_block
    "gwlb"    = aws_subnet.subnet-az2-gwlb.cidr_block
    "mgmt"    = aws_subnet.subnet-az2-mgmt.cidr_block
    "tgw"     = aws_subnet.subnet-az2-tgw.cidr_block
  }
}

output "subnet-az1_ids" {
  value = {
    "private" = aws_subnet.subnet-az1-private.id
    "gwlb"    = aws_subnet.subnet-az1-gwlb.id
    "mgmt"    = aws_subnet.subnet-az1-mgmt.id
    "tgw"     = aws_subnet.subnet-az1-tgw.id
  }
}

output "subnet-az2_ids" {
  value = {
    "private" = aws_subnet.subnet-az2-private.id
    "gwlb"    = aws_subnet.subnet-az2-gwlb.id
    "mgmt"    = aws_subnet.subnet-az2-mgmt.id
    "tgw"     = aws_subnet.subnet-az2-tgw.id
  }
}

output "nsg_ids" {
  value = {
    "public"  = aws_security_group.nsg-vpc-sec-public.id
    "private" = aws_security_group.nsg-vpc-sec-private.id
    "mgmt"    = aws_security_group.nsg-vpc-sec-mgmt.id
    "ha"      = aws_security_group.nsg-vpc-sec-ha.id
  }
}

output "vpc" {
  value = {
    "id" = aws_vpc.vpc-sec.id
  }
}

output "tgw-att-vpc-sec_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-sec.id
}