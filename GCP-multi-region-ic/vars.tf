# GCP resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
}
# GCP project name
variable "project" {
  type    = string
  default = "<Project Name>"
}
# GCP oauth access token
variable "token" {
  type    = string
  default = "<ACCESS TOKEN>"
}
variable "admin-cidr" {
  type    = string
  default = "0.0.0.0/0"
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
  default = "europe-west1-b" #Default Zone
}

# GCP zone
variable "region-2_zone" {
  type    = string
  default = "europe-west4-a" #Default Zone
}

variable "c1_id" {
  type    = string
  default = "c1"
}

variable "c2_id" {
  type    = string
  default = "c2"
}

variable "ipsec-psk-key" {
  type    = string
  default = "super-secret-key"
}

# FortiGate Image name
# 7.0.5 payg is projects/fortigcp-project-001/global/images/fortinet-fgtondemand-705-20220211-001-w-license
# 7.0.5 byol is projects/fortigcp-project-001/global/images/fortinet-fgt-705-20220211-001-w-license
variable "image" {
  type    = string
  default = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-705-20220211-001-w-license"
}

# VM test Image name
variable "image-vm" {
  type    = string
  default = "projects/debian-cloud/global/images/debian-11-bullseye-v20220719"
}

// HTTPS Port
variable "adminsport" {
  type    = string
  default = "8443"
}

# GCP instance machine type
variable "machine" {
  type    = string
  default = "n1-standard-4"
}
# GCP instance machine type for testing vm
variable "machine-vm" {
  type    = string
  default = "e2-micro"
}

# license file for active
variable "licenseFile" {
  type    = string
  default = "license1.lic"
}
# license file for passive
variable "licenseFile2" {
  type    = string
  default = "license2.lic"
}

# active interface VM test ip assignments
variable "vm_spoke1_ip" {
  type    = string
  default = "172.16.4.4"
}
variable "vm_spoke2_ip" {
  type    = string
  default = "172.16.5.4"
}

variable image_family {
  type = string
  description = "Image family. Overriden by providing explicit image name"
  default = "fortigate-72-payg"
  validation {
    condition = can(regex("^fortigate-[67][0-9]-(byol|payg)$", var.image_family))
    error_message = "The image_family is always in form 'fortigate-[major version]-[payg or byol]' (eg. 'fortigate-72-byol')."
  }
}

variable image_name {
  type = string
  description = "Image name. Overrides var.firmware_family"
  default = null
  nullable = true
}


