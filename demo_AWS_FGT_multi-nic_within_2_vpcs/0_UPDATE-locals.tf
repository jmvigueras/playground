#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
#
#  - Multi-VPC ENIs HUB-SPOKE
#  - Only Fortigate cluster type FGCP is supported with this topology
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "multi-vpc"
  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"] // configure 1 or 2 AZs

  #-----------------------------------------------------------------------------------------------------
  # FGT - HUB VPC
  #-----------------------------------------------------------------------------------------------------
  instance_type = "c6i.xlarge"
  fgt_build     = "build1577"
  license_type  = "payg"

  fgt_vpc_cidr = "172.30.0.0/24"
  
  # fgt_subnet_tags: add tags to each FGT subnets (port1, port2, public, private ...) "tag1.tag2" = "subnet-name"
  fgt_subnet_tags = {
    "port1.public" = "public"
    "port2.mgmt"   = "mgmt"
  }

  fgt_vpc_public_subnet_names  = [local.fgt_subnet_tags["port1.public"], local.fgt_subnet_tags["port2.mgmt"]]
  fgt_vpc_private_subnet_names = []

  fgt_number_peer_az = length(local.azs) > 1 ? 1 : 2 // number of fortigates peer AZ
  fgt_cluster_type   = "fgcp" // Onyl FGCP is supported for this topology

  admin_port = "8443"
  admin_cidr = "0.0.0.0/0"

  #-----------------------------------------------------------------------------------------------------
  # SPOKE VPC
  #-----------------------------------------------------------------------------------------------------
  spoke_vpc_number = 2 // Maximum 2 if you are using c6i.xlarge (2 free interfaces remaind)

  spoke_vpc_cidr = { for i in range(0, local.spoke_vpc_number) : "spoke${i + 1}" => "172.30.${100 + i}.0/24" }

  spoke_vpc_public_subnet_names  = ["vm"]
  spoke_vpc_private_subnet_names = ["fgt"]
}


