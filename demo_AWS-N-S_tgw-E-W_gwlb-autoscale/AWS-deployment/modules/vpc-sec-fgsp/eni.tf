#---------------------------------------------------------------------------
# Create interfaces for FGT AZ1
#---------------------------------------------------------------------------

# Create all the eni interfaces FGT FGSP primary AZ1
resource "aws_network_interface" "ni-port1" {
  subnet_id         = aws_subnet.subnet-az1-private.id
  security_groups   = [aws_security_group.nsg-vpc-sec-private.id]
  private_ips       = [cidrhost(aws_subnet.subnet-az1-private.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-fgt-master-port1"
  }
}

resource "aws_network_interface" "ni-port2" {
  subnet_id         = aws_subnet.subnet-az1-mgmt.id
  security_groups   = [aws_security_group.nsg-vpc-sec-mgmt.id, aws_security_group.nsg-vpc-sec-ha.id]
  private_ips       = [cidrhost(aws_subnet.subnet-az1-mgmt.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-fgt-master-port2"
  }
}