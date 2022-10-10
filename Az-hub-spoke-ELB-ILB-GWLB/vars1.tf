
variable "hub-peer" {
  type = map(any)
  default = {
    id              = "hub-peer"
    bgp-asn         = "65002"
    bgp-id          = "10.10.10.253"
    vxlan-ip1       = "10.10.30.253"
    advpn-net       = "10.10.20.0/24"
    public-ip1      = "22.22.22.22"
    hck-srv-ip1     = "172.31.16.10"
    hck-srv-ip2     = "172.31.17.10"
    hck-srv-ip3     = "172.31.19.10"
    cidr            = "172.31.0.0/20"
    advpn-psk       = "secret-psk-key"
  }
}

variable "hub" {
  type = map(any)
  default = {
    id             = "HubAzure"
    bgp-asn        = "65001"
    bgp-id         = "10.10.10.254"
    vxlan-ip1      = "10.10.30.254"
    advpn-net      = "10.10.10.0/24"
    cidr           = "172.30.0.0/20"
  }
}

//Region for HUB Azure deployment
variable "location" {
  type    = string
  default = "francecentral"
}

// CDIR spoke 1
variable "vnet-spoke-1_cidr" {
  default = "172.30.16.0/23"
}

// CDIR spoke 2
variable "vnet-spoke-2_cidr" {
  default = "172.30.18.0/23"
}

// CIDR range for entire network sites
variable "spokes-onprem-cidr" {
  default = "192.168.0.0/16"
}