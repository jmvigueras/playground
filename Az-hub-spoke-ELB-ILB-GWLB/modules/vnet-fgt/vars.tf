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

variable "vnet-fgt_cidr" {
  default = "172.31.0.0/20"
}

// enable accelerate network, either true or false, default is false
// Make the the instance choosed supports accelerated networking.
// Check: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-vm-instances
variable "accelerate" {
  default = "false"
}

// HTTPS Port
variable "admin_port" {
  type    = string
  default = "8443"
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}






