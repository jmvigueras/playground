
variable "hub-peer" {
  type = map(any)
  default = {
    "bgp-asn"        = "65001"
    "public-ip1"     = "11.11.11.11"
    "vxlan-ip1"      = "10.10.30.254"
  }
}

variable "hub" {
  type = map(any)
  default = {
    "id"             = "HubAzure"
    "bgp-asn"        = "65002"
    "bgp-id"         = "10.10.20.254"
    "vxlan-ip1"      = "10.10.30.253"
    "advpn-net"      = "10.10.20.0/24"
  }
}

//Region for HUB Azure deployment
variable "regiona" {
  type    = string
  default = "eastus2"
}

// CDIR range /20 for VNET FGT in region A
variable "vnet-fgt_net" {
  default = "172.31.0.0/20"
}

// CDIR spoke 1
variable "vnet-spoke-1_net" {
  default = "172.31.16.0/23"
}

// CDIR spoke 2
variable "vnet-spoke-2_net" {
  default = "172.31.18.0/23"
}

// CIDR range for entire network sites
variable "spokes-onprem-cidr" {
  default = "192.168.0.0/16"
}

// ADVPN PSK IPSEC Fortinet
variable "advpn-ipsec-psk" {
  default = "jvv7TcGyWnZzScODdA96YVJsW"
}