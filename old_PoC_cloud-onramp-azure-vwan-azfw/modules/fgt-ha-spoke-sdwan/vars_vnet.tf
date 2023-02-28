###################################################################################
# - IMPORTANT - Update this variables with outputs from module ../vnet-fgt
###################################################################################

// Update this variable if you have deployed vnet-fgt
// -> module "github.com/jmvigueras/modules/azure/vnet-fgt`
variable "fgt-active-ni_ids" {
  type    = list(string)
  default = null
}
variable "fgt-passive-ni_ids" {
  type    = list(string)
  default = null
}

variable "fgt-subnet_cidrs" {
  type    = map(any)
  default = null
}

variable "gwlb_ip" {
  type    = string
  default = null
}
