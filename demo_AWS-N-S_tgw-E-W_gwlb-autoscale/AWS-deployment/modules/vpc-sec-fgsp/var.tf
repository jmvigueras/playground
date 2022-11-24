# AWS resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

# AWS resourcers prefix description
variable "tag-env" {
  type    = string
  default = "terraform-deploy"
}

variable "admin_cidr" {
  default = "0.0.0.0/0"
}

variable "admin-sport" {
  default = "8443"
}

variable "vpc-sec_net" {
  default = "172.30.0.0/20"
}

variable "subnet-spoke-vm" {
  type = map(any)
  default = {
    "spoke-1-vm_net" = "172.30.16.0/24"
    "spoke-2-vm_net" = "172.30.17.0/24"
  }
}

variable "tgw_id" {
  default = "tgw_id"
}

variable "gwlb_service-name" {
  type    = string
  default = null
}

variable "region" {
  type = map(any)
  default = {
    "region"     = "eu-west-1"
    "region_az1" = "eu-west-1a"
    "region_az2" = "eu-west-1c"
  }
}