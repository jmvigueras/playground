##############################################################################################################
#
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment -
#
##############################################################################################################
variable "hub-peer" {
  type = map(any)
  default = {
    "bgp-asn"    = "65002"
    "public-ip1" = "11.11.11.11"
    "vxlan-ip1"  = "10.10.30.2"
  }
}

variable "hub" {
  type = map(any)
  default = {
    "id"        = "HubAWS"
    "bgp-asn"   = "65001"
    "bgp-id"    = "10.10.10.1"
    "vxlan-ip1" = "10.10.30.1"
    "advpn-ip1" = "10.10.10.1"
  }
}

variable "sites_bgp-asn" {
  default = "65011"
}

// mpls PSK IPSEC
variable "advpn-ipsec-psk" {
  default = "sample-password"
}
