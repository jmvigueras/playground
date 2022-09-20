# Create all the eni interfaces FGT active
resource "aws_network_interface" "ni-active-port1" {
  subnet_id         = aws_subnet.subnet-az1-mgmt-ha.id
  security_groups   = [aws_security_group.nsg-vpc-sec-mgmt.id, aws_security_group.nsg-vpc-sec-ha.id]
  private_ips       = [cidrhost(aws_subnet.subnet-az1-mgmt-ha.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-active-port1"
  }
}

resource "aws_network_interface" "ni-active-port2" {
  subnet_id         = aws_subnet.subnet-az1-public.id
  security_groups   = [aws_security_group.nsg-vpc-sec-public.id]
  private_ips       = [cidrhost(aws_subnet.subnet-az1-public.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-active-port2"
  }
}

resource "aws_network_interface" "ni-active-port3" {
  subnet_id         = aws_subnet.subnet-az1-private.id
  security_groups   = [aws_security_group.nsg-vpc-sec-private.id]
  private_ips       = [cidrhost(aws_subnet.subnet-az1-private.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-active-port3"
  }
}

# Create all the eni interfaces FGT passive
resource "aws_network_interface" "ni-passive-port1" {
  subnet_id         = aws_subnet.subnet-az2-mgmt-ha.id
  security_groups   = [aws_security_group.nsg-vpc-sec-mgmt.id, aws_security_group.nsg-vpc-sec-ha.id]
  private_ips       = [cidrhost(aws_subnet.subnet-az2-mgmt-ha.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-passive-port1"
  }
}

resource "aws_network_interface" "ni-passive-port2" {
  subnet_id         = aws_subnet.subnet-az2-public.id
  security_groups   = [aws_security_group.nsg-vpc-sec-public.id]
  private_ips       = [cidrhost(aws_subnet.subnet-az2-public.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-passive-port2"
  }
}

resource "aws_network_interface" "ni-passive-port3" {
  subnet_id         = aws_subnet.subnet-az2-private.id
  security_groups   = [aws_security_group.nsg-vpc-sec-private.id]
  private_ips       = [cidrhost(aws_subnet.subnet-az2-private.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-passive-port3"
  }
}