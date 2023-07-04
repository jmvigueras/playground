// Create VPC-SPOKES
module "vpc-spoke" {
  source = "./modules/vpc-spoke"

  prefix      = var.prefix
  admin_cidr  = "${chomp(data.http.my-public-ip.body)}/32"
  admin-sport = var.admin-sport
  region      = var.region

  vpc-spoke-1_net = "172.30.16.0/24"
  vpc-spoke-2_net = "172.30.17.0/24"

  tgw_id            = aws_ec2_transit_gateway.tgw.id
  gwlb_service-name = aws_vpc_endpoint_service.gwlb_service.service_name
}

// Create key-pair
resource "aws_key_pair" "keypair" {
  count      = var.keypair != null ? 0 : 1
  key_name   = "${var.prefix}-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}

data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}

# Get the last AMI Images from AWS MarektPlace FGT on-demand
data "aws_ami_ids" "fgt-ond-amis" {
  owners = ["679593333241"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWSONDEMAND ${var.fgt_build}*"]
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/ssh-key.pem"
  file_permission = "0600"
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}