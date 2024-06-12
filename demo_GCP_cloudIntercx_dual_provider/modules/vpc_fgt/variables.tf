variable "prefix" {
  description = "GCP resourcers prefix description"
  type        = string
  default     = "terraform"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west4"
}

variable "vpc-sec_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "172.30.0.0/23"
}

variable "admin_cidr" {
  description = "Fortigates Admin CIDR to create Firewall rules"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cidr_host" {
  description = "CIDR host to set fortigate IP"
  type        = number
  default     = 10
}
