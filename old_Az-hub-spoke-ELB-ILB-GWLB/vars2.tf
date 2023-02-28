// Azure configuration for Terraform providers
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

// Azure configuration for FGT SDN connector
variable "fgt-subscription_id" {}
variable "fgt-client_id" {}
variable "fgt-client_secret" {}
variable "fgt-tenant_id" {}

# Azure resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

// S2S PSK IPSEC Virtual Network Gateways (MPLS simulation)
variable "s2s-ipsec-psk" {
  default = "sample-password"
}

# Azure resourcers tag
variable "tag_env" {
  type    = string
  default = "terraform-deploy"
}

//  For HA, choose instance size that support 4 nics at least
//  Check : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes
variable "size" {
  type    = string
  default = "Standard_F4"
}

//For testing VMs
variable "size-vm" {
  type    = string
  default = "Standard_B1ms"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  default = "payg"
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

variable "fgtoffer" {
  type    = string
  default = "fortinet_fortigate-vm_v5"
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

// FOS version
variable "fgtversion" {
  type    = string
  default = "7.2.1"
}

variable "adminusername" {
  type    = string
  default = "azureadmin"
}

variable "adminpassword" {
  type    = string
  default = "Terraform123#"
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

// BGP ASN for sites
variable "sites_bgp-asn" {
  type    = string
  default = "65011"
}

// Config template for fortigate cluster in hub
variable "bootstrap-fgt-hub" {
  // Change to your own path
  type    = string
  default = "./templates/fgt-hub.conf"
}

// license file for the active fgt in Region A
variable "license-active" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./licenses/license-active.lic"
}

// license file for the passive fgt in Region A
variable "license-passive" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "./licenses/license-passive.lic"
}

