# VPC CIDR
variable "vpc-site_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "hub1" {
  type = map(any)
  default = {
    bgp-asn     = "65001"
    advpn_pip   = "11.11.11.11"
    advpn-ip1   = "10.10.10.1"
    advpn_cidr  = "10.10.10.0/24"
    hck-srv-ip1 = "172.30.16.10"
    cidr        = "172.30.0.0/20"
    advpn-psk   = "sample-key"
  }
}

variable "hub2" {
  type = map(any)
  default = {
    bgp-asn     = "65002"
    advpn_pip   = "22.22.22.22"
    advpn-ip1   = "10.10.20.1"
    advpn_cidr  = "10.10.20.0/24"
    hck-srv-ip1 = "172.31.16.10"
    cidr        = "172.31.0.0/20"
    advpn_psk   = "sample-key"
  }
}

variable "site" {
  type = map(any)
  default = {
    bgp-asn   = "65011"
    advpn-ip1 = "10.10.10.20"
    advpn-ip2 = "10.10.20.20"
  }
}