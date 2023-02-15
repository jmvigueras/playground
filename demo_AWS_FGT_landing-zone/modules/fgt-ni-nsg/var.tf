# AWS resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "admin_port" {
  type    = string
  default = "8443"
}

variable "subnet_az1_ids" {
  type = map(string)
  default = null
}

variable "subnet_az2_ids" {
  type = map(string)
  default = null
}

variable "subnet_az1_cidrs" {
  type = map(string)
  default = null
}

variable "subnet_az2_cidrs" {
  type = map(string)
  default = null
}

variable "vpc-sec_id" {
  type = string
  default = null
}