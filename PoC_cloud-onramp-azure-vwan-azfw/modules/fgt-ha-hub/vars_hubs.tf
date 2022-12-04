###################################################################################
# - IMPORATANT - Add this variables when call the module with your designed data
###################################################################################
// Details for configure HUB
variable "hub" {
  type = map(any)
  default = {
    id        = "HUBCloud"
    bgp-asn   = "65001"
    advpn-net = "10.10.10.0/24"
    cidr      = "192.168.0.0/24"
    ha        = false
  }
}

// Details for vxlan connection to hub (simulated L2/MPLS)
variable "hub-peer_vxlan" {
  type = map(any)
  default = {
    "bgp-asn"    = "65002"
    "public-ip1" = "11.11.11.11"
    "remote-ip1" = "10.10.30.1"
    "local-ip1"  = "10.10.30.2"
  }
}

variable "spoke_bgp-asn" {
  type    = string
  default = "64552"
}

