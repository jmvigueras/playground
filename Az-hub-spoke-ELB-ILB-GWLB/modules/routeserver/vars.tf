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

variable "vnet_name" {
  type    = string
  default = "spoke-1"
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "fgt_bgp-asn" {
  type    = string
  default = "65002"
}

variable "fgt1_peer-ip" {
  type    = string
  default = "172.31.3.10"
}

variable "fgt2_peer-ip" {
  type    = string
  default = "172.31.3.11"
}



