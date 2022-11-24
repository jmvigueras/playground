// Create site 
module "fgt-site" {
  count  = 2
  source = "./module/fgt"

  vpc-site_net = cidrsubnet(var.vpc-site_cidr, 4, count.index)
  ssh-keys     = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"
  site_id      = count.index
  zone         = var.zone
  admin_port   = var.admin_port
  admin_cidr   = "${chomp(data.http.my-public-ip.body)}/32"
  machine      = var.machine
  prefix       = var.prefix
  hub1         = var.hub1
  hub2         = var.hub2
  site = {
    bgp-asn   = "65011"
    advpn-ip1 = "10.10.10.${count.index + 10}"
    advpn-ip2 = "10.10.20.${count.index + 10}"
  }
}

data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}

data "google_client_openid_userinfo" "me" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/ssh-key.pem"
  file_permission = "0600"
}