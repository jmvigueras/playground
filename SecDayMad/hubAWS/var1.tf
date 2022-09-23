variable "hub-peer" {
  type = map(any)
  default = {
    "bgp-asn"        = "65002"
    "public-ip1"     = "11.11.11.11"
    "vxlan-ip1"      = "10.10.30.253"
  }
}

variable "hub" {
  type = map(any)
  default = {
    "id"             = "HubAWS"
    "bgp-asn"        = "65001"
    "bgp-id"         = "10.10.10.254"
    "vxlan-ip1"      = "10.10.30.254"
    "advpn-net"      = "10.10.10.0/24"
  }
}

variable "sites_bgp-asn" {
  default = "65011"
}

// CIDR range for vpc-se
variable "vpc-sec_net"{
  default = "172.30.0.0/20"
}

// CIDR range for vpc-spoke-1
variable "vpc-spoke-1_net"{
  default = "172.30.16.0/23"
}

// CIDR range for vpc-spoke-1
variable "vpc-spoke-2_net"{
  default = "172.30.18.0/23"
}

// CIDR range for ONPREM sites
variable "spokes-onprem-cidr"{
  default = "192.168.0.0/16"
}

// mpls PSK IPSEC
variable "advpn-ipsec-psk" {
  default = "4v3ry5jlsd87jf3c5h4r3dt8y"
}

