##############################################################################################################
# VPC SPOKE 1 Routes
##############################################################################################################
# Routes
resource "aws_route_table" "rt-spoke-1" {
  vpc_id = aws_vpc.vpc-spoke-1.id
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name = "${var.prefix}-rt-spoke-1"
  }
}

# Route tables associations
resource "aws_route_table_association" "ra-subnet-spoke-1-vm" {
  subnet_id      = aws_subnet.subnet-vpc-spoke-1-vm.id
  route_table_id = aws_route_table.rt-spoke-1.id
}

# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-spoke-1" {
  subnet_ids                                      = [aws_subnet.subnet-vpc-spoke-1-vm.id]
  transit_gateway_id                              = var.tgw_id
  vpc_id                                          = aws_vpc.vpc-spoke-1.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "${var.prefix}-tgw-att-vpc-spoke-1"
  }
}

##############################################################################################################
# VPC SPOKE 2 Routes
##############################################################################################################
# Routes

# Routes
resource "aws_route_table" "rt-spoke-2" {
  vpc_id = aws_vpc.vpc-spoke-2.id
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name = "${var.prefix}-rt-spoke-2"
  }
}

# Route tables associations
resource "aws_route_table_association" "ra-subnet-spoke-2-vm" {
  subnet_id      = aws_subnet.subnet-vpc-spoke-2-vm.id
  route_table_id = aws_route_table.rt-spoke-2.id
}

# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-spoke-2" {
  subnet_ids                                      = [aws_subnet.subnet-vpc-spoke-2-vm.id]
  transit_gateway_id                              = var.tgw_id
  vpc_id                                          = aws_vpc.vpc-spoke-2.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "${var.prefix}-tgw-att-vpc-spoke-2"
  }
}

