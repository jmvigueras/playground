
output "subnet_az1_cidrs" {
  value = {
    mgmt    = aws_subnet.subnet-az1-mgmt-ha.cidr_block
    public  = aws_subnet.subnet-az1-public.cidr_block
    private = aws_subnet.subnet-az1-private.cidr_block
  }
}

output "subnet_az2_cidrs" {
  value = {
    mgmt    = aws_subnet.subnet-az2-mgmt-ha.cidr_block
    public  = aws_subnet.subnet-az2-public.cidr_block
    private = aws_subnet.subnet-az2-private.cidr_block
  }
}

output "subnet_az1_ids" {
  value = {
    mgmt    = aws_subnet.subnet-az1-mgmt-ha.id
    public  = aws_subnet.subnet-az1-public.id
    private = aws_subnet.subnet-az1-private.id
  }
}

output "subnet_az2_ids" {
  value = {
    mgmt    = aws_subnet.subnet-az2-mgmt-ha.id
    public  = aws_subnet.subnet-az2-public.id
    private = aws_subnet.subnet-az2-private.id
  }
}

output "vpc-sec_id" {
  value = aws_vpc.vpc-sec.id
}
