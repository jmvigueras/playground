# Route mgmt
resource "aws_route_table" "rt-mgmt-ha" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-sec.id
  }
  tags = {
    Name = "${local.prefix}-rt-mgmt-ha"
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
    Name = "${local.prefix}-rt-public"
  }
}
/*
# Route private
resource "aws_route_table" "rt-bastion" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-sec.id
  }
  route {
    cidr_block           = "172.16.0.0/12"
    network_interface_id = aws_network_interface.ni-active-private.id
  }
  route {
    cidr_block           = "192.168.0.0/16"
    network_interface_id = aws_network_interface.ni-active-private.id
  }
  route {
    cidr_block           = "10.0.0.0/8"
    network_interface_id = aws_network_interface.ni-active-private.id
  }
  tags = {
    Name = "${local.prefix}-rt-bastion"
  }
}

# Route tgw
resource "aws_route_table" "rt-tgw" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.ni-active-private.id
  }
  tags = {
    Name = "${local.prefix}-rt-tgw"
  }
}

# Route tgw AZ2 subnet
resource "aws_route_table" "rt-tgw-az2" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.ni-active-private.id
  }
  tags = {
    Name = "${local.prefix}-rt-tgw-az2"
  }
}
*/

# Route tables associations AZ1
resource "aws_route_table_association" "ra-subnet-az1-mgmt-ha" {
  subnet_id      = aws_subnet.subnet-az1-mgmt-ha.id
  route_table_id = aws_route_table.rt-mgmt-ha.id
}
resource "aws_route_table_association" "ra-subnet-az1-public" {
  subnet_id      = aws_subnet.subnet-az1-public.id
  route_table_id = aws_route_table.rt-public.id
}
/*
resource "aws_route_table_association" "ra-subnet-az1-private" {
  subnet_id      = aws_subnet.subnet-az1-private.id
  route_table_id = aws_route_table.rt-private.id
}
resource "aws_route_table_association" "ra-subnet-az1-tgw" {
  subnet_id      = aws_subnet.subnet-az1-tgw.id
  route_table_id = aws_route_table.rt-tgw.id
}
resource "aws_route_table_association" "ra-subnet-az1-gwlb" {
  subnet_id      = aws_subnet.subnet-az1-gwlb.id
  route_table_id = aws_route_table.rt-gwlb.id
}
resource "aws_route_table_association" "ra-subnet-az1-bastion" {
  subnet_id      = aws_subnet.subnet-az1-bastion.id
  route_table_id = aws_route_table.rt-bastion.id
}
*/

# Route tables associations AZ2
resource "aws_route_table_association" "ra-subnet-az2-mgmt-ha" {
  subnet_id      = aws_subnet.subnet-az2-mgmt-ha.id
  route_table_id = aws_route_table.rt-mgmt-ha.id
}
resource "aws_route_table_association" "ra-subnet-az2-public" {
  subnet_id      = aws_subnet.subnet-az2-public.id
  route_table_id = aws_route_table.rt-public.id
}
/*
resource "aws_route_table_association" "ra-subnet-az2-private" {
  subnet_id      = aws_subnet.subnet-az2-private.id
  route_table_id = aws_route_table.rt-private.id
}
resource "aws_route_table_association" "ra-subnet-az2-tgw" {
  subnet_id      = aws_subnet.subnet-az2-tgw.id
  route_table_id = aws_route_table.rt-tgw.id
}
resource "aws_route_table_association" "ra-subnet-az2-gwlb" {
  subnet_id      = aws_subnet.subnet-az2-gwlb.id
  route_table_id = aws_route_table.rt-gwlb.id
}
resource "aws_route_table_association" "ra-subnet-az2-bastion" {
  subnet_id      = aws_subnet.subnet-az2-bastion.id
  route_table_id = aws_route_table.rt-bastion.id
}

# Create VPC endpoint GWLB
resource "aws_vpc_endpoint" "gwlbe_az1" {
  count             = local.gwlb_service-name != null ? 1 : 0
  service_name      = local.gwlb_service-name
  subnet_ids        = [aws_subnet.subnet-az1-gwlb.id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = aws_vpc.vpc-sec.id
}

resource "aws_vpc_endpoint" "gwlbe_az2" {
  count             = local.gwlb_service-name != null ? 1 : 0
  service_name      = local.gwlb_service-name
  subnet_ids        = [aws_subnet.subnet-az2-gwlb.id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = aws_vpc.vpc-sec.id
}
*/