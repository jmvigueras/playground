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