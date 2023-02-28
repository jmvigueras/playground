#----------------------------------------------------------------------------------
# - IMPORATANT - Update this variables with your wished scenario
#----------------------------------------------------------------------------------

## Update these variables in terraform.tfvars ##

variable "azfw_id" {
  type    = string
  default = null
}

variable "vhub_id" {
  type    = string
  default = null
}

variable "vhub_peer-ip" {
  type    = list(string)
  default = null
}

variable "vwan_new-vnet_cidr" {
  type    = list(string)
  default = null
}