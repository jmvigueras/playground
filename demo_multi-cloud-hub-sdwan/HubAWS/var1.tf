variable "hub-peer" {
  type = map(any)
  default = {
    "bgp-asn"    = "65002"
    "public-ip1" = "22.22.22.22"
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
    "advpn-net" = "10.10.10.0/24"
  }
}

variable "sites_bgp-asn" {
  default = "65011"
}

variable "region" {
  type = map(any)
  default = {
    "region"     = "eu-west-1"
    "region_az1" = "eu-west-1a"
    "region_az2" = "eu-west-1c"
  }
}

// CIDR range for vpc-se
variable "vpc-sec_net" {
  default = "172.30.0.0/20"
}

// CIDR range for vpc-spoke-1
variable "vpc-spoke-1_net" {
  default = "172.30.16.0/23"
}

// CIDR range for vpc-spoke-1
variable "vpc-spoke-2_net" {
  default = "172.30.18.0/23"
}

// CIDR range for ONPREM sites
variable "spokes-onprem-cidr" {
  default = "192.168.0.0/16"
}

