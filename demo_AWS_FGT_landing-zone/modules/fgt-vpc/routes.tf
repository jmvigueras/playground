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

# Route tables associations AZ1
resource "aws_route_table_association" "ra-subnet-az1-mgmt-ha" {
  subnet_id      = aws_subnet.subnet-az1-mgmt-ha.id
  route_table_id = aws_route_table.rt-mgmt-ha.id
}
resource "aws_route_table_association" "ra-subnet-az1-public" {
  subnet_id      = aws_subnet.subnet-az1-public.id
  route_table_id = aws_route_table.rt-public.id
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