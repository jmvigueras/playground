##############################################################################################################
# VPC SPOKE 1
##############################################################################################################
resource "aws_vpc" "vpc-spoke-1" {
  cidr_block           = var.vpc-spoke-1_net
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc-spoke-1"
  }
}

# IGW
resource "aws_internet_gateway" "igw-vpc-spoke-1" {
  vpc_id = aws_vpc.vpc-spoke-1.id
  tags = {
    Name = "${var.prefix}-igw-vpc-spoke-1"
  }
}

# Subnets
resource "aws_subnet" "subnet-vpc-spoke-1-vm" {
  vpc_id            = aws_vpc.vpc-spoke-1.id
  cidr_block        = cidrsubnet(var.vpc-spoke-1_net,1,0)
  availability_zone = var.region["region_az1"]
  tags = {
    Name = "${var.prefix}-subnet-vpc-spoke-1-vm"
  }
}


##############################################################################################################
# VPC SPOKE 2
##############################################################################################################

resource "aws_vpc" "vpc-spoke-2" {
  cidr_block           = var.vpc-spoke-2_net
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc-spoke-2"
  }
}

# IGW
resource "aws_internet_gateway" "igw-vpc-spoke-2" {
  vpc_id = aws_vpc.vpc-spoke-2.id
  tags = {
    Name = "${var.prefix}-igw-vpc-spoke-2"
  }
}

# Subnets
resource "aws_subnet" "subnet-vpc-spoke-2-vm" {
  vpc_id            = aws_vpc.vpc-spoke-2.id
  cidr_block        = cidrsubnet(var.vpc-spoke-2_net,1,0)
  availability_zone = var.region["region_az2"]
  tags = {
    Name = "${var.prefix}-subnet-vpc-spoke-2-vm"
  }
}