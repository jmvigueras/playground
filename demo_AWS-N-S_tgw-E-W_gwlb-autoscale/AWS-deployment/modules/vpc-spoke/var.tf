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
  type    = string
  default = "0.0.0.0/0"
}

variable "admin-sport" {
  type    = string
  default = "8443"
}

variable "vpc-sec_net" {
  type    = string
  default = "172.30.0.0/20"
}

variable "vpc-spoke-1_net" {
  type    = string
  default = "172.30.16.0/23"
}

variable "vpc-spoke-2_net" {
  type    = string
  default = "172.30.18.0/23"
}

variable "tgw_id" {
  type    = string
  default = null
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