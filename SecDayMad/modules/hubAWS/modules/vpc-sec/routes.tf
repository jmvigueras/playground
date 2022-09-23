# Route mgmt
resource "aws_route_table" "rt-mgmt-ha" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-sec.id
  }
  tags = {
    Name = "${var.prefix}-rt-mgmt-ha"
  }
}

# Route public
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-sec.id
  }
  route {
    cidr_block            = var.vpc-spoke-1_net
    network_interface_id  = aws_network_interface.ni-active-port3.id
  }
  route {
    cidr_block            = var.vpc-spoke-2_net
    network_interface_id  = aws_network_interface.ni-active-port3.id
  }
  tags = {
    Name = "${var.prefix}-rt-public"
  }
}

# Route private
resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id  = aws_network_interface.ni-active-port2.id
  }
  route {
    cidr_block         = var.vpc-spoke-1_net
    transit_gateway_id = var.tgw_id
  }
  route {
    cidr_block         = var.vpc-spoke-2_net
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name = "${var.prefix}-rt-private"
  }
}

# Route tgw
resource "aws_route_table" "rt-tgw" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id  = aws_network_interface.ni-active-port3.id
  }
  tags = {
    Name = "${var.prefix}-rt-twg"
  }
}


# Route tables associations AZ1
resource "aws_route_table_association" "ra-subnet-az1-mgmt-ha" {
  subnet_id      = aws_subnet.subnet-az1-mgmt-ha.id
  route_table_id = aws_route_table.rt-mgmt-ha.id
}

resource "aws_route_table_association" "ra-subnet-az1-public" {
  subnet_id      = aws_subnet.subnet-az1-public.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "ra-subnet-az1-private" {
  subnet_id      = aws_subnet.subnet-az1-private.id
  route_table_id = aws_route_table.rt-private.id
}

/* (Future use)
resource "aws_route_table_association" "ra-subnet-az1-mpls" {
  subnet_id      = aws_subnet.subnet-az1-mpls.id
  route_table_id = aws_route_table.rt-public.id
}
*/

resource "aws_route_table_association" "ra-subnet-az1-tgw" {
  subnet_id      = aws_subnet.subnet-az1-tgw.id
  route_table_id = aws_route_table.rt-tgw.id
}

# Route tables associations AZ2
resource "aws_route_table_association" "ra-subnet-az2-mgmt-ha" {
  subnet_id      = aws_subnet.subnet-az2-mgmt-ha.id
  route_table_id = aws_route_table.rt-mgmt-ha.id
}

resource "aws_route_table_association" "ra-subnet-az2-public" {
  subnet_id      = aws_subnet.subnet-az2-public.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "ra-subnet-az2-private" {
  subnet_id      = aws_subnet.subnet-az2-private.id
  route_table_id = aws_route_table.rt-private.id
}

/* (Future use)
resource "aws_route_table_association" "ra-subnet-az2-mpls" {
  subnet_id      = aws_subnet.subnet-az2-mpls.id
  route_table_id = aws_route_table.rt-public.id
}
*/

resource "aws_route_table_association" "ra-subnet-az2-tgw" {
  subnet_id      = aws_subnet.subnet-az2-tgw.id
  route_table_id = aws_route_table.rt-tgw.id
}


# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-sec" {
  subnet_ids                                      = [aws_subnet.subnet-az1-tgw.id, aws_subnet.subnet-az2-tgw.id]
  transit_gateway_id                              = var.tgw_id
  vpc_id                                          = aws_vpc.vpc-sec.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "${var.prefix}-tgw-att-vpc-sec"
  }
}


