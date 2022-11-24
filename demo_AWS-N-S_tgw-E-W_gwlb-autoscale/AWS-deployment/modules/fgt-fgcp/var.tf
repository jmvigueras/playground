# AWS resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

# AWS resourcers prefix description
variable "tag-env" {
  type    = string
  default = "terraform-deploy"
}

variable "tags" {
  description = "Attribute for tag Enviroment"
  type        = map(any)
  default = {
    project = "terraform"
  }
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "admin-sport" {
  type    = string
  default = "8443"
}

variable "api_key" {
  type    = string
  default = null
}

// mpls PSK IPSEC
variable "advpn-ipsec-psk" {
  type    = string
  default = "sample-password"
}

variable "spokes-onprem-cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "vpc-sec_net" {
  type    = string
  default = "172.30.0.0/20"
}

variable "vpc-spoke-1_net" {
  type    = string
  default = "172.30.16.0/23"
}

variable "vpc-spoke-2_net" {
  type    = string
  default = "172.30.18.0/23"
}

variable "region" {
  type = map(any)
  default = {
    "region"     = "eu-west-1"
    "region_az1" = "eu-west-1a"
    "region_az2" = "eu-west-1c"
  }
}

variable "sites_bgp-asn" {
  type    = string
  default = "65011"
}

variable "hub-peer" {
  type = map(any)
  default = {
    "bgp_asn"       = "65002"
    "ip_public-ip1" = "11.11.11.11"
    "vxlan-ip1"     = "10.10.30.253"
  }
}

variable "hub" {
  type = map(any)
  default = {
    "id"        = "HubAWS"
    "bgp_asn"   = "65002"
    "bgp_id"    = "10.10.10.254"
    "vxlan-ip1" = "10.10.30.253"
    "advpn-ip1" = "10.10.10.253"
  }
}

variable "eni-active" {
  type = map(any)
  default = {
    "port1_id" = "port1_id"
    "port2_id" = "port2_id"
    "port3_id" = "port3_id"
    "port4_id" = "port4_id"
    "port1_ip" = "172.30.1.10"
    "port2_ip" = "172.30.2.10"
    "port3_ip" = "172.30.3.10"
    "port4_ip" = "172.30.4.10"
  }
}

variable "eni-passive" {
  type = map(any)
  default = {
    "port1_id" = "port1_id"
    "port2_id" = "port2_id"
    "port3_id" = "port3_id"
    "port4_id" = "port4_id"
    "port1_ip" = "172.30.11.10"
    "port2_ip" = "172.30.12.10"
    "port3_ip" = "172.30.13.10"
    "port4_ip" = "172.30.14.10"
  }
}

variable "subnet-az1-vpc-sec" {
  type = map(any)
  default = {
    "public_net"  = "172.30.2.0/24"
    "private_net" = "172.30.3.0/24"
    "mpls_net"    = "172.30.4.0/24"
    "mgmt-ha_net" = "172.30.1.0/24"
  }
}

variable "subnet-az2-vpc-sec" {
  type = map(any)
  default = {
    "public_net"  = "172.30.12.0/24"
    "private_net" = "172.30.13.0/24"
    "mpls_net"    = "172.30.14.0/24"
    "mgmt-ha_net" = "172.30.11.0/24"
  }
}

variable "subnet-vpc-spoke" {
  type = map(any)
  default = {
    "spoke-1-vm_net" = "172.30.16.0/24"
    "spoke-2-vm_net" = "172.30.18.0/24"
  }
}

// AMI
variable "fgt-ami" {
  type    = string
  default = "null"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  type    = string
  default = "payg"
}

// license file for the active fgt
variable "license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "license.txt"
}

// license file for the passive fgt
variable "license2" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "license2.txt"
}

variable "instance_type" {
  description = "Provide the instance type for the FortiGate instances"
  default     = "c5.large"
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