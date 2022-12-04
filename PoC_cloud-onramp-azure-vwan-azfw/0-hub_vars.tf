// Variable used for creating simulated HUB in Azure
variable "hub_cloud" {
  type = map(any)
  default = {
    id        = "DC0"
    bgp-asn   = "65001"
    advpn-net = "10.10.10.0/24"
    cidr      = "192.168.50.0/24"
    ha        = false
  }
}