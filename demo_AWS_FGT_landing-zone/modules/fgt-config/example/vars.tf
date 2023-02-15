#-----------------------------------------------------------------------------------
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

variable "mgmt_port" {
  type    = string
  default = "port1"
}
variable "public_port" {
  type    = string
  default = "port2"
}
variable "private_port" {
  type    = string
  default = "port3"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  type    = string
  default = "payg"
}

// license file for the active fgt
variable "license_file_1" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./licenses/license1.lic"
}

// license file for the passive fgt
variable "license_file_2" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "./licenses/license2.lic"
}

variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  default     = "<key pair>"
}

// SSH RSA public key for KeyPair if not exists
variable "rsa-public-key" {
  type    = string
  default = null
}

variable "api_key" {
  type    = string
  default = null
}