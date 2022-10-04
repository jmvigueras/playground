# GCP resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}

variable "c_id" {
  type    = string
  default = "c1"
}

# GCP region
variable "region-1" {
  type    = string
  default = "europe-west1" #Default Region
}

variable "region-2" {
  type    = string
  default = "europe-west4" #Default Region
}

# GCP zone
variable "region-1_zone" {
  type    = string
  default = "europe-west1-a" #Default Zone
}

# GCP zone
variable "region-2_zone" {
  type    = string
  default = "europe-west4-a" #Default Zone
}

# GCP instance machine type
variable "machine" {
  type    = string
  default = "n1-standard-4"
}

// HTTPS Port
variable "adminsport" {
  type    = string
  default = "8443"
}

variable "ipsec-psk-key" {
  type    = string
  default = "super-secret-key-123"
}

variable "api-key" {
  type    = string
  default = "supersecrettoken123"
}

variable "admin-cidr" {
  type    = string
  default = "0.0.0.0/0"
}

# FortiGate Image name
# 7.0.5 payg is projects/fortigcp-project-001/global/images/fortinet-fgtondemand-705-20220211-001-w-license
# 7.0.5 byol is projects/fortigcp-project-001/global/images/fortinet-fgt-705-20220211-001-w-license
variable "image" {
  type    = string
  default = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-705-20220211-001-w-license"
}

variable "subnet_names" {
  type = map(any)
  default = {
    mgmt-ha-r1        = "prefix-subnet-mgmt-ha-r1"
    mgmt-ha-r2        = "prefix-subnet-mgmt-ha-r2"
    ic-1-s1           = "prefix-subnet-ic-1-s1"
    ic-1-s2           = "prefix-subnet-ic-1-s2"
    ic-2-s1           = "prefix-subnet-ic-2-s1"
    ic-2-s2           = "prefix-subnet-ic-2-s2"
    private-fgt-r1    = "prefix-subnet-private-fgt-r1"
    private-fgt-r2    = "prefix-subnet-private-fgt-r1"
  }
}

variable "subnet_cidrs" {
  type = map(any)
  default = {
    mgmt-ha-r1        = "172.16.1.0/25"
    mgmt-ha-r2        = "172.16.1.128/25"
    ic-1-s1           = "172.16.2.0/26"
    ic-1-s2           = "172.16.2.64/26"
    ic-2-s1           = "172.16.3.0/26"
    ic-2-s2           = "172.16.3.64/26"
    private-fgt-r1    = "172.16.4.0/26"
    private-fgt-r2    = "172.16.4.64/26"
    private-pro       = "172.16.4.128/26"
  }
}

variable "ic-peer_cidrs" {
  type = map(any)
  default = {
    ic-1          = "172.17.2.0/25"
    ic-2          = "172.17.3.0/25"
    ic-pro        = "172.17.4.128/26"
  }
}

variable "ic-peer_ips" {
  type = map(any)
  default = {
    ic-1          = "172.17.2.10"
    ic-2          = "172.17.3.10"
    ic-hck        = "172.17.4.138"
  }
}