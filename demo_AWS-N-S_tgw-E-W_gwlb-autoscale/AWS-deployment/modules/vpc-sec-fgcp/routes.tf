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
  tags = {
    Name = "${var.prefix}-rt-public"
  }
}

# Route private
resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.ni-active-port2.id
  }
  route {
    cidr_block         = var.subnet-spoke-vm["spoke-1-vm_net"]
    transit_gateway_id = var.tgw_id
  }
  route {
    cidr_block         = var.subnet-spoke-vm["spoke-2-vm_net"]
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name = "${var.prefix}-rt-private"
  }
}

# Route gwlb
resource "aws_route_table" "rt-gwlb" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name = "${var.prefix}-rt-gwlb"
  }
}

# Route tgw AZ1 subnet
resource "aws_route_table" "rt-tgw-az1" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.ni-active-port3.id
  }
  /*
  route {
    cidr_block      = "10.0.0.0/8"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbe_az1.id
  }
  route {
    cidr_block      = "172.16.0.0/12"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbe_az1.id
  }
  */
  tags = {
    Name = "${var.prefix}-rt-tgw-az1"
  }
}

# Route tgw AZ2 subnet
resource "aws_route_table" "rt-tgw-az2" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.ni-active-port3.id
  }
  /*
  route {
    cidr_block      = "10.0.0.0/8"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbe_az2.id
  }
  route {
    cidr_block      = "172.16.0.0/12"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbe_az2.id
  }
  */
  tags = {
    Name = "${var.prefix}-rt-tgw-az2"
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

resource "aws_route_table_association" "ra-subnet-az1-tgw" {
  subnet_id      = aws_subnet.subnet-az1-tgw.id
  route_table_id = aws_route_table.rt-tgw-az1.id
}

resource "aws_route_table_association" "ra-subnet-az1-gwlb" {
  subnet_id      = aws_subnet.subnet-az1-gwlb.id
  route_table_id = aws_route_table.rt-gwlb.id
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

resource "aws_route_table_association" "ra-subnet-az2-tgw" {
  subnet_id      = aws_subnet.subnet-az2-tgw.id
  route_table_id = aws_route_table.rt-tgw-az2.id
}

resource "aws_route_table_association" "ra-subnet-az2-gwlb" {
  subnet_id      = aws_subnet.subnet-az2-gwlb.id
  route_table_id = aws_route_table.rt-gwlb.id
}

# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-sec" {
  subnet_ids                                      = [aws_subnet.subnet-az1-tgw.id, aws_subnet.subnet-az2-tgw.id]
  transit_gateway_id                              = var.tgw_id
  vpc_id                                          = aws_vpc.vpc-sec.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${var.prefix}-tgw-att-vpc-sec"
  }
}

# Create VPC endpoint GWLB
resource "aws_vpc_endpoint" "gwlbe_az1" {
  service_name      = var.gwlb_service-name
  subnet_ids        = [aws_subnet.subnet-az1-gwlb.id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = aws_vpc.vpc-sec.id
}

resource "aws_vpc_endpoint" "gwlbe_az2" {
  service_name      = var.gwlb_service-name
  subnet_ids        = [aws_subnet.subnet-az2-gwlb.id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = aws_vpc.vpc-sec.id
}