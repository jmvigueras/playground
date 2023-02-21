output "vpc-sec_id" {
  value = aws_vpc.vpc-sec.id
}

output "subnet_az1_cidrs" {
  value = {
    mgmt    = aws_subnet.subnet-az1-mgmt-ha.cidr_block
    public  = aws_subnet.subnet-az1-public.cidr_block
    private = aws_subnet.subnet-az1-private.cidr_block
    bastion = aws_subnet.subnet-az1-bastion.cidr_block
    tgw     = aws_subnet.subnet-az1-tgw.cidr_block
    gwlb    = aws_subnet.subnet-az1-gwlb.cidr_block
  }
}

output "subnet_az2_cidrs" {
  value = {
    mgmt    = aws_subnet.subnet-az2-mgmt-ha.cidr_block
    public  = aws_subnet.subnet-az2-public.cidr_block
    private = aws_subnet.subnet-az2-private.cidr_block
    bastion = aws_subnet.subnet-az2-bastion.cidr_block
    tgw     = aws_subnet.subnet-az2-tgw.cidr_block
    gwlb    = aws_subnet.subnet-az2-gwlb.cidr_block
  }
}

output "subnet_az1_ids" {
  value = {
    mgmt    = aws_subnet.subnet-az1-mgmt-ha.id
    public  = aws_subnet.subnet-az1-public.id
    private = aws_subnet.subnet-az1-private.id
    bastion = aws_subnet.subnet-az1-bastion.id
    tgw     = aws_subnet.subnet-az1-tgw.id
    gwlb    = aws_subnet.subnet-az1-gwlb.id
  }
}

output "subnet_az2_ids" {
  value = {
    mgmt    = aws_subnet.subnet-az2-mgmt-ha.id
    public  = aws_subnet.subnet-az2-public.id
    private = aws_subnet.subnet-az2-private.id
    bastion = aws_subnet.subnet-az2-bastion.id
    tgw     = aws_subnet.subnet-az2-tgw.id
    gwlb    = aws_subnet.subnet-az2-gwlb.id
  }
}

