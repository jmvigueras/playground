# Create all the eni interfaces for test VM
resource "aws_network_interface" "ni-vm-spoke-1" {
  subnet_id         = aws_subnet.subnet-vpc-spoke-1-vm.id
  security_groups   = [aws_security_group.nsg-vpc-spoke-1-vm.id]
  private_ips       = [cidrhost(aws_subnet.subnet-vpc-spoke-1-vm.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-vm-spoke-1"
  }
}

resource "aws_network_interface" "ni-vm-spoke-2" {
  subnet_id         = aws_subnet.subnet-vpc-spoke-2-vm.id
  security_groups   = [aws_security_group.nsg-vpc-spoke-2-vm.id]
  private_ips       = [cidrhost(aws_subnet.subnet-vpc-spoke-2-vm.cidr_block, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-vm-spoke-2"
  }
}
