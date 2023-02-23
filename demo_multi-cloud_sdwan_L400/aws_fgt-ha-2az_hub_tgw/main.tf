#-----------------------------------------------------------------------
# Necessary variables

data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}
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

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}

# Get the last AMI Images from AWS MarektPlace FGT PAYG
data "aws_ami_ids" "fgt_amis_payg" {
  owners = ["679593333241"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWSONDEMAND ${local.fgt_build}*"]
  }
}

# Get the last AMI Images from AWS MarektPlace FGT BYOL
data "aws_ami_ids" "fgt_amis_byol" {
  owners = ["679593333241"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWS ${local.fgt_build}*"]
  }
}