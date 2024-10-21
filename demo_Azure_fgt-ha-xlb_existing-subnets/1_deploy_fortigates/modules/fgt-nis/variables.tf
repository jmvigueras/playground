// Azure resourcers group
variable "resource_group_name" {
  type    = string
  default = null
}

// Region for deployment
variable "location" {
  type    = string
  default = "francecentral"
}

// Azure resourcers prefix description added in name
variable "prefix" {
  type    = string
  default = "module-vnet-fgt"
}

// Azure resourcers tags
variable "tags" {
  type = map(any)
  default = {
    deploy = "module-vnet-fgt"
  }
}

// enable accelerate network, either true or false, default is false
// Make the the instance choosed supports accelerated networking.
// Check: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-vm-instances
variable "accelerate" {
  type        = bool
  default     = true
  description = "Boolean viriable to config accelerated interfaces"
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.accelerate))
    error_message = "accelerate must be either true or false."
  }
}

// HTTPS Port
variable "admin_port" {
  type    = string
  default = "8443"
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "subnet_cidrs" {
  type = map(string)
  default = null
}

variable "subnet_ids" {
  type = map(string)
  default = null
}

