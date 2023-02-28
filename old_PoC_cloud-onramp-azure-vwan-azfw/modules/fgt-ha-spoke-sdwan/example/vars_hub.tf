###################################################################################
# - IMPORATANT - Update this variables with your wished scenario
###################################################################################
// Default parameters for HUBs
variable "hubs" {
  type = list(map(string))
  default = [
    {
      id         = "HUB1"
      bgp-asn    = "65001"
      public-ip  = "11.11.11.11"
      hub-ip     = "172.20.30.1"
      site-ip    = "172.20.30.12"
      hck-srv-ip = "172.20.30.1"
      advpn-psk  = "secret-key"
      cidr       = "172.20.30.0/24"
    },
    {
      id         = "HUB2"
      bgp-asn    = "65002"
      public-ip  = "22.22.22.22"
      hub-ip     = "172.25.30.1"
      site-ip    = "172.25.30.12"
      hck-srv-ip = "172.25.30.1"
      advpn-psk  = "secret-key"
      cidr       = "172.25.30.0/24"
    }
  ]
}

// Default parameters for Site
variable "site" {
  type = map(any)
  default = {
    id      = "site-1"
    cidr    = "192.168.0.0/24"
    bgp-asn = "65011"
    ha      = true
  }
}