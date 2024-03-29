#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {

  prefix     = "fgt-ha" // prefix added to all deployed assets in tag Name
  admin_port = "8443"
  admin_cidr = "0.0.0.0/0"

  instance_type = "c6i.xlarge"
  fgt_build     = "build1396"

  fgt_license_type   = "byol"
  fgt_license_file_1 = "./licenses/license1.lic"
  fgt_license_file_2 = "./licenses/license2.lic"

  vpc-spoke_cidr = ["172.30.100.0/23"] // cidrs of VPC spoke attached to TGW (summarized range)

  region = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }

  keypair_name   = null
  rsa-public-key = null

  fgt_vpc_id = "vpc-06d70705833cdc91f"

  fgt_subnet_az1_cidrs = {
    mgmt    = "172.30.0.0/27"
    private = "172.30.0.64/27"
    public  = "172.30.0.32/27"
  }
  fgt_subnet_az1_ids = {
    mgmt    = "subnet-0dc4d47b5b1d008e6"
    private = "subnet-012672131b19b0048"
    public  = "subnet-00ad8aa9a558db2a8"
  }
  fgt_subnet_az2_cidrs = {
    mgmt    = "172.30.1.0/27"
    private = "172.30.1.64/27"
    public  = "172.30.1.32/27"
  }
  fgt_subnet_az2_ids = {
    mgmt    = "subnet-076d62ade3a20ca2c"
    private = "subnet-0aed14cf128f1dcdf"
    public  = "subnet-0bcce7b3d955e068b"
  }
}


#-----------------------------------------------------------------------
# Necessary variables

// Create key-pair
resource "aws_key_pair" "keypair" {
  key_name   = "${local.prefix}-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}