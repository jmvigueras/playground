// Resource group name
variable "resource_group_name" {
  type    = string
  default = null
}

// Azure resourcers prefix description added in name
variable "prefix" {
  type    = string
  default = "terraform"
}

// Azure resourcers tags
variable "tags" {
  type = map(string)
  default = {
    deploy = "module-xlb"
  }
}

// Region for deployment
variable "location" {
  type    = string
  default = "francecentral"
}

// Map of subnet IDs VNet FGT
variable "subnet_ids" {
  type    = map(string)
  default = null
}

// Map of subnet CIDRS VNet FGT
variable "subnet_cidrs" {
  type    = map(string)
  default = null
}

// VNET ID of FGT VNET for peering
variable "vnet-fgt" {
  type    = map(string)
  default = null
}

// Fortigate IPs
variable "fgt-active-ni_ips" {
  type    = map(string)
  default = null
}
variable "fgt-passive-ni_ips" {
  type    = map(string)
  default = null
}

variable "ilb_ip" {
  type    = string
  default = null
}

// Floating IPs
variable "elb_floating_ip" {
  type = bool
  default = false
}
variable "ilb_floating_ip" {
  type = bool
  default = false
}

// List of ports to open (listernes)
variable "elb_listeners" {
  type = map(string)
  default = {
    "80"   = "Tcp"
    "443"  = "Tcp"
    "500"  = "Udp"
    "4500" = "Udp"
    "4789" = "Udp"
  }
}

// Fortigate interface probe port
variable "backend-probe_port" {
  type    = string
  default = "8008"
}