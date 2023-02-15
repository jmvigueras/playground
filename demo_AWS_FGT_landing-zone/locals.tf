#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {

  prefix        = "fgt-ha"
  admin_port    = "8443"
  admin_cidr    = "0.0.0.0/0"
  instance_type = "c6i.xlarge"
  fgt_build     = "build1396"
  license_type  = "byol"

  fgt = {
    id   = "fgt"
    cidr = "172.30.0.0/24"
  }

  vpc-spoke_cidr = "172.30.100.0/23"

  region = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }

  keypair_name   = null
  rsa-public-key = null
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