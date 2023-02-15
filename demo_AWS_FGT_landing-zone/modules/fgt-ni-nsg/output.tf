output "fgt-active-ni_ids" {
  value = {
    mgmt    = aws_network_interface.ni-active-mgmt.id
    public  = aws_network_interface.ni-active-public.id
    private = aws_network_interface.ni-active-private.id
  }
}

output "fgt-active-ni_ips" {
  value = {
    mgmt    = aws_network_interface.ni-active-mgmt.private_ip
    public  = aws_network_interface.ni-active-public.private_ip
    private = aws_network_interface.ni-active-private.private_ip
  }
}

output "fgt-passive-ni_ids" {
  value = {
    mgmt    = aws_network_interface.ni-passive-mgmt.id
    public  = aws_network_interface.ni-passive-public.id
    private = aws_network_interface.ni-passive-private.id
  }
}

output "fgt-passive-ni_ips" {
  value = {
    mgmt    = aws_network_interface.ni-passive-mgmt.private_ip
    public  = aws_network_interface.ni-passive-public.private_ip
    private = aws_network_interface.ni-passive-private.private_ip
  }
}

output "nsg_ids" {
  value = {
    mgmt    = aws_security_group.nsg-vpc-sec-mgmt.id
    ha      = aws_security_group.nsg-vpc-sec-ha.id
    private = aws_security_group.nsg-vpc-sec-private.id
    public  = aws_security_group.nsg-vpc-sec-public.id
  }
}