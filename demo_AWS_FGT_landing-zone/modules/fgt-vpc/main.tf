##############################################################################################################
# Create VPC SEC and Subnets
# - VPC security
# - Subnets AZ1: mgmt, public, private
# - Subnets AZ1: mgmt, public, private
##############################################################################################################
resource "aws_vpc" "vpc-sec" {
  cidr_block           = var.vpc-sec_cidr
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
    Name = "${var.prefix}-igw"
  }
}

# Subnets AZ1
resource "aws_subnet" "subnet-az1-mgmt-ha" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_cidr, 4, 0)
  availability_zone = var.region["az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-mgmt-ha"
  }
}

resource "aws_subnet" "subnet-az1-public" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_cidr, 4, 1)
  availability_zone = var.region["az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-public"
  }
}

resource "aws_subnet" "subnet-az1-private" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_cidr, 4, 2)
  availability_zone = var.region["az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-private"
  }
}

# Subnets AZ2
resource "aws_subnet" "subnet-az2-mgmt-ha" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_cidr, 4, 8)
  availability_zone = var.region["az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-mgmt-ha"
  }
}

resource "aws_subnet" "subnet-az2-public" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_cidr, 4, 9)
  availability_zone = var.region["az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-public"
  }
}

resource "aws_subnet" "subnet-az2-private" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = cidrsubnet(var.vpc-sec_cidr, 4, 10)
  availability_zone = var.region["az2"]
  tags = {
    Name = "${var.prefix}-subnet-az2-private"
  }
}
