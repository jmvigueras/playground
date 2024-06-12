# GCP resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}
variable "suffix" {
  type    = string
  default = "1"
}
# GCP region
variable "region" {
  type    = string
  default = "europe-west4" #Default Region
}

# GCP zone
variable "zone1" {
  type    = string
  default = "europe-west4-a" #Default Zone
}

# GCP zone
variable "zone2" {
  type    = string
  default = "europe-west4-a" #Default Zone
}

variable "fgt_active_self_link" {
  type    = string
  default = null
}

variable "fgt_passive_self_link" {
  type    = string
  default = null
}

variable "backend-probe_port" {
  type    = string
  default = "8008"
}

variable "ilb_ip_private_1" {
  type    = string
  default = null
}

variable "ilb_ip_private_2" {
  type    = string
  default = null
}

variable "ilb_ip_public" {
  type    = string
  default = null
}

variable "config_spoke_route" {
  type    = bool
  default = false
}

variable "vpc_spoke_names" {
  type    = list(string)
  default = null
}

variable "subnet_names" {
  type    = map(string)
  default = null
}

variable "vpc_names" {
  type    = map(string)
  default = null
}

variable "elb_frontend_pip_id" {
  type    = string
  default = null
}
