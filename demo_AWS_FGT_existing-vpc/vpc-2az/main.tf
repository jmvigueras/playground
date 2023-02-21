##############################################################################################################
# Create VPC SEC and Subnets
# - VPC security
# - Subnets AZ1: mgmt, public, private, TGW, GWLB
# - Subnets AZ1: mgmt, public, private, TGW, GWLB
##############################################################################################################
resource "aws_vpc" "vpc-sec" {
  cidr_block           = local.vpc-sec_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.prefix}-vpc-sec"
  }
}

# IGW
resource "aws_internet_gateway" "igw-vpc-sec" {
  vpc_id = aws_vpc.vpc-sec.id
  tags = {
    Name = "${local.prefix}-igw"
  }
}

# Subnets AZ1
resource "aws_subnet" "subnet-az1-mgmt-ha" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az1_mgmt_cidr
  availability_zone = local.region["az1"]
  tags = {
    Name = "${local.prefix}-subnet-az1-mgmt-ha"
  }
}

resource "aws_subnet" "subnet-az1-public" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az1_public_cidr
  availability_zone = local.region["az1"]
  tags = {
    Name = "${local.prefix}-subnet-az1-public"
  }
}

resource "aws_subnet" "subnet-az1-private" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az1_private_cidr
  availability_zone = local.region["az1"]
  tags = {
    Name = "${local.prefix}-subnet-az1-private"
  }
}

resource "aws_subnet" "subnet-az1-tgw" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az1_tgw_cidr
  availability_zone = local.region["az1"]
  tags = {
    Name = "${local.prefix}-subnet-az1-tgw"
  }
}

resource "aws_subnet" "subnet-az1-gwlb" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az1_gwlb_cidr
  availability_zone = local.region["az1"]
  tags = {
    Name = "${local.prefix}-subnet-az1-gwlb"
  }
}

resource "aws_subnet" "subnet-az1-bastion" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az1_bastion_cidr
  availability_zone = local.region["az1"]
  tags = {
    Name = "${local.prefix}-subnet-az1-bastion"
  }
}

# Subnets AZ2
resource "aws_subnet" "subnet-az2-mgmt-ha" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az2_mgmt_cidr
  availability_zone = local.region["az2"]
  tags = {
    Name = "${local.prefix}-subnet-az2-mgmt-ha"
  }
}

resource "aws_subnet" "subnet-az2-public" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az2_public_cidr
  availability_zone = local.region["az2"]
  tags = {
    Name = "${local.prefix}-subnet-az2-public"
  }
}

resource "aws_subnet" "subnet-az2-private" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az2_private_cidr
  availability_zone = local.region["az2"]
  tags = {
    Name = "${local.prefix}-subnet-az2-private"
  }
}

resource "aws_subnet" "subnet-az2-tgw" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az2_tgw_cidr
  availability_zone = local.region["az2"]
  tags = {
    Name = "${local.prefix}-subnet-az2-tgw"
  }
}

resource "aws_subnet" "subnet-az2-gwlb" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az2_gwlb_cidr
  availability_zone = local.region["az2"]
  tags = {
    Name = "${local.prefix}-subnet-az2-gwlb"
  }
}

resource "aws_subnet" "subnet-az2-bastion" {
  vpc_id            = aws_vpc.vpc-sec.id
  cidr_block        = local.subnet_az2_bastion_cidr
  availability_zone = local.region["az2"]
  tags = {
    Name = "${local.prefix}-subnet-az2-bastion"
  }
}