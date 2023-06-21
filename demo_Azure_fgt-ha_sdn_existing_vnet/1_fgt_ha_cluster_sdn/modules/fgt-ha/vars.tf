variable "storage-account_endpoint" {}
variable "resource_group_name" {}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}
variable "admin_password" {}

# Azure resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
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

variable "fgt_ni_0" {
  type    = string
  default = "public"
}
variable "fgt_ni_1" {
  type    = string
  default = "private"
}
variable "fgt_ni_2" {
  type    = string
  default = "mgmt"
}

//  For HA, choose instance size that support 4 nics at least
//  Check : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes
variable "size" {
  type    = string
  default = "Standard_F4"
}

variable "location" {
  type    = string
  default = "francecentral"
}

// Azure resourcers tags
variable "tags" {
  type = map(any)
  default = {
    Deploy  = "module-fgt-ha"
    Project = "terraform-fortinet"
  }
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  type    = string
  default = "payg"
}

// enable accelerate network, either true or false, default is false
// Make the the instance choosed supports accelerated networking.
// Check: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-vm-instances
variable "accelerate" {
  type    = string
  default = "false"
}

// AMI
variable "fgt_sku" {
  type = map(string)
  default = {
    byol = "fortinet_fg-vm"
    payg = "fortinet_fg-vm_payg_2022"
  }
}

variable "publisher" {
  type    = string
  default = "fortinet"
}

variable "fgt_offer" {
  type    = string
  default = "fortinet_fortigate-vm_v5"
}

variable "fgt_version" {
  type    = string
  default = "latest"
}

// license file for the active fgt
variable "license-active" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "/license-active.txt"
}

// license file for the passive fgt
variable "license-passive" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "/license-passive.txt"
}