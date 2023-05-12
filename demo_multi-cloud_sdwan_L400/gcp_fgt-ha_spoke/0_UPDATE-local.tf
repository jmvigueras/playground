locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  region  = "europe-west2"
  zone1   = "europe-west2-a"
  zone2   = "europe-west2-a"
  prefix  = "demo-multi-cloud"
  machine = "n1-standard-4"

  admin_port   = "8443"
  admin_cidr   = "${chomp(data.http.my-public-ip.response_body)}/32"
  license_type = "payg"

  spoke = {
    id      = "spoke"
    cidr    = "192.168.0.0/23" //minimum range to create proxy subnet
    bgp_asn = "65000"
  }
  vpc_spoke-subnet_cidrs = ["192.168.10.0/23","192.168.20.0/23"]

  ncc_bgp-asn = "65515"

  fgt_passive = true

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB locals
  #-----------------------------------------------------------------------------------------------------
  hubs = [local.hubs_1[0], local.hubs_1[1], local.hubs_2[0]]

  hubs_1 = data.terraform_remote_state.aws_fgt-ha-2az_hub_tgw.outputs.hubs
  hubs_2 = data.terraform_remote_state.az_fgt-ha_hub_xlb-vwan.outputs.hubs

  #-----------------------------------------------------------------------------------------------------
  # FAZ and FMG IPs
  #-----------------------------------------------------------------------------------------------------
  faz_ip = data.terraform_remote_state.aws_fgt-ha-2az_hub_tgw.outputs.faz["private_ip"]
  fmg_ip = data.terraform_remote_state.aws_fgt-ha-2az_hub_tgw.outputs.fmg["private_ip"]
}



#-----------------------------------------------------------------------------------------------------
# Import tfsate file from AWS and Azure deployment
#-----------------------------------------------------------------------------------------------------
// Import data from deployment az_fgt-ha_hub-spoke_xlb-vwan
data "terraform_remote_state" "az_fgt-ha_hub_xlb-vwan" {
  backend = "local"
  config = {
    path = "../az_fgt-ha_hub_xlb-vwan/terraform.tfstate"
  }
}
// Import data from deployment aws_fgt-ha-2az_hub-spoke_tgw
data "terraform_remote_state" "aws_fgt-ha-2az_hub_tgw" {
  backend = "local"
  config = {
    path = "../aws_fgt-ha-2az_hub_tgw/terraform.tfstate"
  }
}

#------------------------------------------------------------------------------------------------------------
# Necessary variables
#------------------------------------------------------------------------------------------------------------
// GET deploy public IP for management
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}

data "google_client_openid_userinfo" "me" {}

resource "tls_private_key" "ssh-rsa" {
  algorithm = "RSA"
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh-rsa.private_key_pem
  filename        = ".ssh/ssh-key.pem"
  file_permission = "0600"
}