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

variable "admin_cidr"{
  default = "0.0.0.0/0"
}

variable "admin_port"{
  default = "8443"
}

// mpls PSK IPSEC
variable "advpn-ipsec-psk" {
  default = "sample-password"
}

variable "spokes-onprem-cidr"{
  default = "192.168.0.0/16"
}

variable "vpc-sec_net"{
  default = "172.30.0.0/20"
}

variable "vpc-spoke-1_net"{
  default = "172.30.16.0/23"
}

variable "vpc-spoke-2_net"{
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
  default = "65011"
}

variable "hub-peer" {
  type = map(any)
  default = {
    "bgp_asn"        = "65002"
    "public-ip1"     = "11.11.11.11"
    "vxlan-ip1"      = "10.10.30.253"
  }
}

variable "hub" {
  type = map(any)
  default = {
    "id"             = "HubAWS"
    "bgp_asn"        = "65002"
    "bgp_id"         = "10.10.10.254"
    "vxlan-ip1"      = "10.10.30.253"
    "advpn-net"      = "10.10.10.0/24"
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
    "public_net"    = "172.30.2.0/24"
    "private_net"   = "172.30.3.0/24"
    "mpls_net"      = "172.30.4.0/24"
    "mgmt-ha_net"   = "172.30.1.0/24"
  }
}

variable "subnet-az2-vpc-sec" {
  type = map(any)
  default = {
    "public_net"    = "172.30.12.0/24"
    "private_net"   = "172.30.13.0/24"
    "mpls_net"      = "172.30.14.0/24"
    "mgmt-ha_net"   = "172.30.11.0/24"
  }
}

variable "subnet-vpc-spoke" {
  type = map(any)
  default = {
    "spoke-1-vm_net"    = "172.30.16.0/24"
    "spoke-2-vm_net"    = "172.30.18.0/24"
  }
}

// AMIs are for FGTVM-AWS(PAYG) - 7.2.0
variable "fgt-ond-amis" {
  type = map(any)
  default = {
    us-east-1      = "ami-035a7ca1d22b2ac60"
    us-east-2      = "ami-0c89751940e00028a"
    us-west-1      = "ami-027023effe0d0cbcb"
    us-west-2      = "ami-0e18da7f57b1455de"
    af-south-1     = "ami-0020b49aee42aac43"
    ap-east-1      = "ami-040df30827808387e"
    ap-southeast-3 = "ami-08b193fa0e26053bc"
    ap-south-1     = "ami-03ce0208e1bf0a4c2"
    ap-northeast-3 = "ami-0dba0e863219fbd2c"
    ap-northeast-2 = "ami-01966ce84e55ce9af"
    ap-southeast-1 = "ami-0abcebf6fa84ec1c9"
    ap-southeast-2 = "ami-0d4a09cac89f2cb2b"
    ap-northeast-1 = "ami-08e9a008d439bd92d"
    ca-central-1   = "ami-0f575e9fe174cc613"
    eu-central-1   = "ami-09b319a3f356c62a3"
    eu-west-1      = "ami-0295b18e7c5c68440"
    eu-west-2      = "ami-0e0cf6ee5949311d3"
    eu-south-1     = "ami-00c0fd80460334680"
    eu-west-3      = "ami-0a2f70eeaccb4f756"
    eu-north-1     = "ami-0980a6c5462eb20c7"
    me-south-1     = "ami-0e971c7104d9ab577"
    sa-east-1      = "ami-0f857d7ef57d996d7"
 }
}

// AMIs are for FGTVM AWS(BYOL) - 7.2.0
variable "fgtvmbyolami" {
  type = map(any)
  default = {
    us-east-1      = "ami-08a9244de2d3b3cfa"
    us-east-2      = "ami-0b07d15df1781b3d8"
    us-west-1      = "ami-02dc2d7ea094493d6"
    us-west-2      = "ami-0c0dcf7b73b82c9b1"
    af-south-1     = "ami-0d74ee5597e3ef661"
    ap-east-1      = "ami-0a0c5c6454847d23a"
    ap-southeast-3 = "ami-028cc9519f272bcb6"
    ap-south-1     = "ami-085942a3a94223f47"
    ap-northeast-3 = "ami-09b93acca6bd3596c"
    ap-northeast-2 = "ami-0cf302c5443f1ebb0"
    ap-southeast-1 = "ami-0a766a36e6c0b330e"
    ap-southeast-2 = "ami-0b658e3ca1fc97423"
    ap-northeast-1 = "ami-0daa2ffa06df3702f"
    ca-central-1   = "ami-07f812bb597b8c317"
    eu-central-1   = "ami-0d049e761ea8dbffc"
    eu-west-1      = "ami-0caa0716272a43357"
    eu-west-2      = "ami-09dc1af4df14fd469"
    eu-south-1     = "ami-0767c696d9d0d5f9f"
    eu-west-3      = "ami-0820c09066de0e77e"
    eu-north-1     = "ami-06828be5bef414e7d"
    me-south-1     = "ami-054c0c3be39202670"
    sa-east-1      = "ami-07fe117d69adc5f80"
  }
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
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
  default     = "c5.xlarge"
}

variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  default     = "<key pair>"
}

variable "bootstrap-fgt" {
  // Change to your own path
  type    = string
  default = "fgt.conf"
}