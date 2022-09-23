variable "resourcegroup_name" {}

# Azure resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

# Azure resourcers prefix description
variable "tag_env" {
  type    = string
  default = "terraform-deploy"
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "vnet-spoke-1_net" {
  default = "172.31.16.0/23"
}

variable "vnet-spoke-2_net" {
  default = "172.31.18.0/23"
}








