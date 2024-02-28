#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "multi-vpc-eni"
  region = "eu-west-1"
  azs    = ["eu-west-1a"]
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  admin_port = "8443"
  # admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"
  admin_cidr = "0.0.0.0/0"

  instance_type = "c6i.xlarge"
  fgt_build     = "build1577"
  license_type  = "payg"

  fgt_cluster_type   = "fgcp"
  fgt_number_peer_az = 2

  fgt_vpc_1_cidr = "172.30.0.0/24"
  fgt_vpc_2_cidr = "172.30.10.0/24"

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  fgt_subnet_tags = {
    "port1.public"  = "public"
    "port2.private" = "private"
    "port3.mgmt"    = "mgmt"
  }

  vpc_1_public_subnet_names  = [local.fgt_subnet_tags["port1.public"], local.fgt_subnet_tags["port3.mgmt"], "bastion"]
  vpc_1_private_subnet_names = [local.fgt_subnet_tags["port2.private"]]

  vpc_2_public_subnet_names  = ["bastion"]
  vpc_2_private_subnet_names = ["private"]
}
