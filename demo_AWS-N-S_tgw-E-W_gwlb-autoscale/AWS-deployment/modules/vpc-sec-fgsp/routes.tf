# Route mgmt
resource "aws_route_table" "rt-mgmt" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-sec.id
  }
  tags = {
    Name = "${var.prefix}-rt-mgmt"
  }
}

# Route private
resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.vpc-sec.id
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

# Route tgw
resource "aws_route_table" "rt-tgw-az1" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbe_az1.id
  }
  tags = {
    Name = "${var.prefix}-rt-twg-az1"
  }
}
resource "aws_route_table" "rt-tgw-az2" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbe_az1.id
  }
  tags = {
    Name = "${var.prefix}-rt-twg-az2"
  }
}

# Route tables associations AZ1
resource "aws_route_table_association" "ra-subnet-az1-mgmt-ha" {
  subnet_id      = aws_subnet.subnet-az1-mgmt.id
  route_table_id = aws_route_table.rt-mgmt.id
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
  subnet_id      = aws_subnet.subnet-az2-mgmt.id
  route_table_id = aws_route_table.rt-mgmt.id
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