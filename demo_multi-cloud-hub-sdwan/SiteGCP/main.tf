// Create site 
module "fgt-site" {
  count  = 2
  source = "./module/fgt"

  vpc-site_net = cidrsubnet(var.vpc-site_cidr, 4, count.index)
  site_id      = count.index
  zone         = var.zone
  admin_port   = var.admin_port
  admin_cidr   = var.admin_cidr
  machine      = var.machine
  hub1         = var.hub1
  hub2         = var.hub2
  site = {
    bgp-asn   = "65011"
    advpn-ip1 = "10.10.10.${count.index + 10}"
    advpn-ip2 = "10.10.20.${count.index + 10}"
  }
}


