// Azure configuration
variable "subscription_id" {
  type    = string
  default = ""
}
variable "client_id" {
  type    = string
  default = ""
}
variable "client_secret" {
  type    = string
  default = ""
}
variable "tenant_id" {
  type    = string
  default = ""
}

variable "storage-account_endpoint" {
  type    = string
  default = null
}
variable "resourcegroup_name" {
  type    = string
  default = null
}

variable "adminusername" {
  type    = string
  default = null
}
variable "adminpassword" {
  type    = string
  default = null
}

# Azure resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

// Azure resourcers tags
variable "tags" {
  type = map(any)
  default = {
    deploy = "module-vnet-spoke"
  }
}

# Azure region
variable "location" {
  type    = string
  default = "europe-west4" // Default Region
}

// HTTPS Port
variable "admin_port" {
  type    = string
  default = "8443"
}

// HTTPS Port
variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

// SSH RSA public key for KeyPair if not exists
variable "rsa-public-key" {
  type    = string
  default = null
}

//  For HA, choose instance size that support 4 nics at least
//  Check : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes
variable "size" {
  type    = string
  default = "Standard_F4"
}

variable "license_type" {
  // Default type payg, to bring your own license configure byol
  type    = string
  default = "payg" // or byol
}

// license file for fgt-active
variable "license-active" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./licenses/license-active.lic"
}

// license file for fgt
variable "license-passive" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./licenses/license-passive.lic"
}

// enable accelerate network, either true or false, default is false
// Make the the instance choosed supports accelerated networking.
// Check: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-vm-instances
variable "accelerate" {
  default = "false"
}

variable "publisher" {
  type    = string
  default = "fortinet"
}

// BYOL sku: fortinet_fg-vm
// PAYG sku: fortinet_fg-vm_payg_2022
variable "fgtsku" {
  type = map(any)
  default = {
    byol = "fortinet_fg-vm"
    payg = "fortinet_fg-vm_payg_2022"
  }
}

variable "fgtoffer" {
  type    = string
  default = "fortinet_fortigate-vm_v5"
}

// FOS version
variable "fgtversion" {
  type    = string
  default = "7.2.2"
}