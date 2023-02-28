// Default parameters for HUBs
// - List of HUBs collections to configure IPSEC tunnels and SDWAN (check example to know collection attributes)
// - It will create necessary config for each HUB described in list
variable "hubs" {
  type    = list(map(string))
  default = null
}

// Default parameters for Site
variable "site" {
  type = map(any)
  default = {
    id      = "site-1"
    cidr    = "192.168.0.0/20"
    bgp-asn = "65011"
    ha      = true
  }
}


#---------------------------------------------------------------------------------
# Example how to add hubs to config
# - Add collections of hubs
# - Add detail for each HUB following the attributes
# - For same id the config for SDWAN zone will be the same adding healch check server and new IPSEC tunnels

/*
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
      advpn-psk  = "secret"
      cidr       = "172.20.30.0/24"
      network_id = "10"
    },
    {
      id         = "HUB1"
      bgp-asn    = "65001"
      public-ip  = "11.11.11.12"
      hub-ip     = "172.25.30.1"
      site-ip    = "172.25.30.12"
      hck-srv-ip = "172.25.30.1"
      advpn-psk  = "secret"
      cidr       = "172.25.30.0/24"
      network_id = "10"
    },
    {
      id         = "HUB2"
      bgp-asn    = "65002"
      public-ip  = "22.22.22.22"
      hub-ip     = "172.25.30.1"
      site-ip    = "172.25.30.12"
      hck-srv-ip = "172.25.30.1"
      advpn-psk  = "secret"
      cidr       = "172.25.30.0/24"
      network_id = "10"
    }
  ]
}
*/