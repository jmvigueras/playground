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

variable "subnet-private" {
  type = map(any)
  default = {
    cidr      = "172.31.3.0/24"
    id        = ""
    vnet_id   = ""
  }
}

variable "fgt-ni_ids" {
  type = map(any)
  default = {
    fgt1-public     = ""
    fgt1-private    = ""
    fgt2-public     = ""
    fgt2-private    = ""
  }
}

variable "fgt-ni_ips" {
  type = map(any)
  default = {
    fgt1-public     = "172.31.2.10"
    fgt1-private    = "172.31.3.10"
    fgt2-public     = "172.31.2.11"
    fgt2-private    = "172.31.3.11"
  }
}

variable "backend-probe_port" {
  type    = string
  default = "8008"
}