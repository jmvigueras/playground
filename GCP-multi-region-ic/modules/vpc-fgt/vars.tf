# GCP resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

variable "c_id" {
  type    = string
  default = "c1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.16.0.0/21"
}

# GCP region
variable "region-1" {
  type    = string
  default = "europe-west1" #Default Region
}

variable "region-2" {
  type    = string
  default = "europe-west4" #Default Region
}


