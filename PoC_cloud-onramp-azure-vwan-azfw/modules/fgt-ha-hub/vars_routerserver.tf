###################################################################################
# - IMPORTANT - Update this variables with outputs from module ../routeserver
###################################################################################

// Update this variable if you have deployed RouteServers
// -> module "github.com/jmvigueras/modules/azure/routeserver`
variable "rs_bgp-asn" {
  type    = string
  default = "65515"
}

// Defalut values for Azure Route Server
variable "rs_peers" {
  type    = list(list(string))
  default = null
}