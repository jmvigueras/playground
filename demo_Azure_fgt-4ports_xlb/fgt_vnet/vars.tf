// Azure configuration for Terraform providers
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

// Resource group name
variable "resource_group_name" {
  type    = string
  default = null
}

// Azure resourcers prefix description added in name
variable "prefix" {
  type    = string
  default = "module-vnet-fgt"
}

// Azure resourcers tags
variable "tags" {
  type = map(any)
  default = {
    Deploy  = "module-vnet-fgt"
    Project = "terraform-deploy"
  }
}

// Region for deployment
variable "location" {
  type    = string
  default = "francecentral"
}

// CIDR range for VNET Fortigate - Security VNET
variable "vnet-fgt_cidr" {
  type    = string
  default = "172.30.0.0/23"
}








