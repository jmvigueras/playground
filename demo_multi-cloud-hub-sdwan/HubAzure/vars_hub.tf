###################################################################################
# - IMPORTANT - Update this variables with your wished scenario
###################################################################################
// FGT cluster data for configuring ADVPN
variable "hub" {
  type = map(any)
  default = {
    "id"        = "HubAazure"
    "bgp-asn"   = "65002"
    "advpn-net" = "10.10.20.0/24"
  }
}

// Details for vxlan configuration to hub for simulating private connection to hub
// - public IP to hub peer to establish new vxlan connection (use standard udp port)
// - private IP of hub peer to establish the BGP session
// - private IP to configure in vxlan interface
variable "hub-peer_vxlan" {
  type = map(any)
  default = {
    "bgp-asn"    = "65001"
    "public-ip1" = "54.246.228.195"
    "remote-ip1" = "10.10.30.1"
    "local-ip1"  = "10.10.30.2"
  }
}

// BGP ASN for site FGT
variable "spoke_bgp-asn" {
  type    = string
  default = "65011"
}