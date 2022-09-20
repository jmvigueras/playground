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

variable "admin_cidr"{
  default = "0.0.0.0/0"
}

variable "admin_port"{
  default = "8443"
}

variable "vpc-sec_net"{
  default = "172.30.0.0/20"
}

variable "vpc-spoke-1_net"{
  default = "172.30.16.0/23"
}

variable "vpc-spoke-2_net"{
  default = "172.30.18.0/23"
}

variable "tgw_id"{
  default = "tgw_id"
}

variable "region" {
  type = map(any)
  default = {
    "region"     = "eu-west-1"
    "region_az1" = "eu-west-1a"
    "region_az2" = "eu-west-1c"
  }
}