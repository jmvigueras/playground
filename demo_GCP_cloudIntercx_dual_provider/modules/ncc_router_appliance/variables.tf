variable "prefix" {
  description = "GCP resourcers prefix description"
  type        = string
  default     = "terraform"
}

variable "region" {
  description = "GCP region to deploy"
  type        = string
  default     = "europe-west4"
}

variable "vpc_name" {
  description = "VPC name to create Cloud Router"
  type        = string
}

variable "fgt_self_link" {
  description = "Fortigate instance cluster member 1 SelfLink, used to create Network Appliance"
  type        = string
}

variable "fgt_ip" {
  description = "Fortigate instance cluster member 1 IP, used to create Network Appliance"
  type        = string
}

variable "ncc_hub_id" {
  description = "Network Connectivity Center ID"
  type        = string
}