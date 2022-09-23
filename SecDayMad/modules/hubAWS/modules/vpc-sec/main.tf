##############################################################################################################
# VPC SECURITY
##############################################################################################################
resource "aws_vpc" "vpc-sec" {
  cidr_block           = var.vpc-sec_net
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc-sec"
  }
}

# IGW
resource "aws_internet_gateway" "igw-vpc-sec" {
  vpc_id = aws_vpc.vpc-sec.id
  tags = {
    Name = "${var.prefix}-igw-vpc-sec"
  }
}

# Subnets AZ1
resource "aws_subnet" "subnet-az1-mgmt-ha" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,4,1)
  availability_zone = var.region["region_az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-mgmt-ha"
  }
}

resource "aws_subnet" "subnet-az1-public" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,4,2)
  availability_zone = var.region["region_az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-public"
  }
}

resource "aws_subnet" "subnet-az1-private" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,4,3)
  availability_zone = var.region["region_az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-private"
  }
}

/* (Future use)
resource "aws_subnet" "subnet-az1-mpls" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,4,4)
  availability_zone = var.region["region_az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-mpls"
  }
}
*/

resource "aws_subnet" "subnet-az1-tgw" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,5,10)
  availability_zone = var.region["region_az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-tgw"
  }
}

# Subnets AZ2
resource "aws_subnet" "subnet-az2-mgmt-ha" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,4,11)
  availability_zone = var.region["region_az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-mgmt-ha"
  }
}

resource "aws_subnet" "subnet-az2-public" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,4,12)
  availability_zone = var.region["region_az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-public"
  }
}

resource "aws_subnet" "subnet-az2-private" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,4,13)
  availability_zone = var.region["region_az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-private"
  }
}

/* (Future use)
resource "aws_subnet" "subnet-az2-mpls" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,4,14)
  availability_zone = var.region["region_az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-mpls"
  }
}
*/

resource "aws_subnet" "subnet-az2-tgw" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_net,5,12)
  availability_zone = var.region["region_az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-tgw"
  }
}
