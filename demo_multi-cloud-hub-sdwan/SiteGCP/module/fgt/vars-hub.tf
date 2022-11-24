# VPC CIDR
variable "vpc-site_net" {
  type    = string
  default = "192.168.16.0/20"
}

variable "hub1" {
  type = map(any)
  default = {
    bgp-asn     = "65001"
    advpn_pip   = "63.35.107.204"
    advpn-ip1   = "10.10.10.1"
    hck-srv-ip1 = "172.30.16.10"
    cidr        = "172.30.0.0/20"
    advpn-psk   = "ts5d6fPf2OUksHiA2upFIeIQa"
  }
}

variable "hub2" {
  type = map(any)
  default = {
    bgp-asn     = "65002"
    advpn_pip   = "20.216.186.119"
    advpn-ip1   = "10.10.20.1"
    hck-srv-ip1 = "172.31.16.10"
    cidr        = "172.31.0.0/20"
    advpn-psk   = "sS3bbTrrDOZ1MQk5drYgu7skh9AwSv"
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