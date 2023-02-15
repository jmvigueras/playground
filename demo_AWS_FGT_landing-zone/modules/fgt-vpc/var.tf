# AWS resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

variable "vpc-sec_cidr" {
  type    = string
  default = "172.30.0.0/23"
}

variable "region" {
  type = map(any)
  default = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }
}