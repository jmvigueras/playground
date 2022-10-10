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

variable "vnet-spoke-1_cidr" {
  default = "172.30.16.0/23"
}

variable "vnet-spoke-2_cidr" {
  default = "172.30.18.0/23"
}








