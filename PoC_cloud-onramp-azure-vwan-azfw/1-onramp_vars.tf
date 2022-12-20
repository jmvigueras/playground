###################################################################################
# - IMPORATANT - Update this variables with your wished scenario
###################################################################################
// Default parameters for FGT on-ramp
variable "site_onramp" {
  type = map(any)
  default = {
    id      = "onramp"
    cidr    = "172.23.136.0/24"
    bgp-asn = "64552"
    ha      = false
  }
}

// Details of HUBs to connect to
// - SDWAN configuration in Fortigate will be deployed using the list of HUBs
// - List all HUBs to connect and detail information of each one using this collection
variable "hubs" {
  type = list(map(string))
  default = [
    {
      id         = "DC1"
      bgp-asn    = "64552"
      public-ip  = "11.11.11.11"
      hub-ip     = "172.20.30.1"
      site-ip    = "172.20.30.12"
      hck-srv-ip = "172.20.30.1"
      advpn-psk  = "super-secret-key"
      cidr       = "172.20.30.0/24"
      network_id = "10"

    },
    {
      id         = "DC1"
      bgp-asn    = "64552"
      public-ip  = "11.11.11.12"
      hub-ip     = "172.20.40.1"
      site-ip    = "172.20.40.12"
      hck-srv-ip = "172.20.40.1"
      advpn-psk  = "super-secret-key"
      cidr       = "172.20.40.0/24"
      network_id = "11"
    },
    {
      id         = "DC2"
      bgp-asn    = "64552"
      public-ip  = "11.11.11.13"
      hub-ip     = "172.25.30.1"
      site-ip    = "172.25.30.12"
      hck-srv-ip = "172.25.30.1"
      advpn-psk  = "super-secret-key"
      cidr       = "172.25.30.0/24"
      network_id = "12"
    },
    {
      id         = "DC2"
      bgp-asn    = "64552"
      public-ip  = "11.11.11.14"
      hub-ip     = "172.25.40.1"
      site-ip    = "172.25.40.12"
      hck-srv-ip = "172.25.30.1"
      advpn-psk  = "super-secret-key"
      cidr       = "172.25.40.0/24"
      network_id = "13"
    }
  ]
}



