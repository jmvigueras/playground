# VPC CIDR
variable "vpc-site_net" {
  type    = string
  default = "192.168.0.0/20"
}

variable "hub1" {
  type = map(any)
  default = {
    bgp-asn         = "65001"
    public-ip1      = "11.11.11.11"
    advpn-ip1       = "10.10.10.1"
    hck-srv-ip1     = "172.30.16.10"
    cidr            = "172.30.0.0/20"
  }
}

variable "hub2" {
  type = map(any)
  default = {
    bgp-asn         = "65002"
    public-ip1      = "22.22.22.22"
    advpn-ip1       = "10.10.20.1"
    hck-srv-ip1     = "172.31.16.4"
    cidr            = "172.31.0.0/20"
  }
}

variable "site" {
  type = map(any)
  default = {
    bgp-asn         = "65011"
    advpn-ip1       = "10.10.10.10"
    advpn-ip2       = "10.10.20.10"
  }
}

// ADVPN PSK IPSEC
variable "advpn-ipsec-psk" {
  default = "update-from-hubs-deployment"
}