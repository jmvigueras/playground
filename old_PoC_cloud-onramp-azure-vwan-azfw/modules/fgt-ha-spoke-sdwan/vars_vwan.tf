variable "vhub_bgp-asn" {
  default = "65515"
}

// Defualt value for vHUB RouteServer
variable "vhub_peer" {
  type    = list(string)
  default = null
}