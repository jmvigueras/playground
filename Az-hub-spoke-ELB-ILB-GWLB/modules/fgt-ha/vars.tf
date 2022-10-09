// Azure configuration
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "storage-account_endpoint" {}
variable "resourcegroup_name" {}

variable "adminusername" {}
variable "adminpassword" {}

// HTTPS Port
variable "admin_port" {
  type    = string
  default = "8443"
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

# Azure resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
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

variable "fgt-active-ni_ids" {
  type = list(string)
  default = ["ni-port1_id", "ni-port2_id", "ni-port3_id", "ni-port4_id"]
}

variable "fgt-active-ni_names" {
  type = list(string)
  default = ["ni-port1_name", "ni-port2_name", "ni-port3_name", "ni-port4_name"]
}

variable "fgt-passive-ni_ids" {
  type = list(string)
  default = ["ni-port1_id", "ni-port2_id", "ni-port3_id", "ni-port4_id"]
}

variable "fgt-passive-ni_names" {
  type = list(string)
  default = ["ni-port1_name", "ni-port2_name", "ni-port3_name", "ni-port4_name"]
}

variable "fgt-ni-nsg_ids"{
  type = list(string)
  default = ["nsg-mgmt-ha_id", "nsg-public_id", "nsg-private_id", "nsg-private_id"]
}

variable "spoke-subnet_cidrs"{
  type = map(any)
  default = {
    spoke-1_subnet1 = "172.31.16.0/25"
    spoke-1_subnet2 = "172.31.17.0/25"
    spoke-1_subnet1 = "172.31.18.0/25"
    spoke-1_subnet2 = "172.31.19.0/25"
  }
}

variable "spoke-vnet_cidrs"{
  type = map(any)
  default = {
    spoke-1    = "172.31.16.0/23"
    spoke-2    = "172.31.18.0/23"
  }
}

variable "fgt-subnet_cidrs"{
  type = map(any)
  default = {
    mgmt      = "172.31.1.0/24"
    public    = "172.31.2.0/24"
    private   = "172.31.3.0/24"
    advpn     = "172.31.4.0/24"
  }
}

variable "hub-peer" {
  type = map(any)
  default = {
    "bgp-asn"        = "65001"
    "public-ip1"     = "11.11.11.11"
    "vxlan-ip1"      = "10.10.30.253"
  }
}

variable "hub" {
  type = map(any)
  default = {
    "id"             = "HubAWS"
    "bgp-asn"        = "65002"
    "bgp-id"         = "10.10.10.254"
    "vxlan-ip1"      = "10.10.30.253"
    "advpn-net"      = "10.10.20.0/24"
  }
}

variable "rs-spoke" {
  type = map(any)
  default = {
    rs1_ip1          = "172.31.17.132"
    rs1_ip2          = "172.31.17.133"
    rs1_bgp-asn      = "65515"
    rs2_ip1          = "172.31.19.132"
    rs2_ip2          = "172.31.19.133"
    rs2_bgp-asn      = "65515"
  }
}

variable "gwlb_ip" {
  default = "172.31.3.15"
}

variable "sites_bgp-asn" {
  default = "65011"
}

variable "cluster-public-ip_name" {
  type    = string
  default = "cluster-public-ip"
}

variable "rt-private_name" {
  type    = string
  default = "rt-private"
}

variable "rt-spoke_name" {
  type    = string
  default = "rt-spoke"
}

variable "spokes-onprem-cidr" {
  default = "192.168.0.0/16"
}

// ADVPN PSK IPSEC 
variable "advpn-ipsec-psk" {
  default = "sample-password"
}

// S2S PSK IPSEC 
variable "s2s-ipsec-psk" {
  default = "sample-password"
}

# Azure resourcers prefix description
variable "tag_env" {
  type    = string
  default = "terraform-deploy"
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

// FOS version
variable "fgtversion" {
  type    = string
  default = "7.2.1"
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

variable "fgt-bgp-asn" {
  type    = string
  default = "65001"
}

variable "sites-bgp-asn" {
  type    = string
  default = "65011"
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

