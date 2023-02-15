# AWS resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

variable "tags" {
  description = "Attribute for tag Enviroment"
  type        = map(any)
  default = {
    project = "terraform"
  }
}

variable "region" {
  type = map(any)
  default = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }
}

variable "fgt_passive" {
  type    = bool
  default = false
}

variable "fgt_ha_fgsp" {
  type    = bool
  default = false
}

variable "fgt_config_1" {
  type    = string
  default = ""
}

variable "fgt_config_2" {
  type    = string
  default = ""
}

variable "fgt-active-ni_ids" {
  type    = map(string)
  default = null
}

variable "fgt-passive-ni_ids" {
  type    = map(string)
  default = null
}

variable "keypair" {
  type    = string
  default = "null"
}

variable "instance_type" {
  description = "Provide the instance type for the FortiGate instances"
  type        = string
  default     = "c6i.large"
}

variable "fgt_ni_0" {
  type    = string
  default = "mgmt"
}
variable "fgt_ni_1" {
  type    = string
  default = "public"
}
variable "fgt_ni_2" {
  type    = string
  default = "private"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  type    = string
  default = "payg"
}

variable "fgt_build" {
  type    = string
  default = "build1396"
}