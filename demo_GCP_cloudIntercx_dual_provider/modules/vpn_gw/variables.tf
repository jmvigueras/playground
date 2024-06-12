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

variable "vpc_id" {
  type    = string
}

variable "peer_ip" {
  type    = string
  default = "15.200.0.10"
}

variable "vpn_psk" {
  type    = string
  default = "secre-key"
}

variable "local_traffic_selector" {
  type    = string
  default = "0.0.0.0/0"
}

variable "remote_traffic_selector" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ike_version" {
  type    = number
  default = 2
}

variable "router_self_link" {
  type    = string
}

variable "vpn_static_ip" {
  type = string
  default = null
}