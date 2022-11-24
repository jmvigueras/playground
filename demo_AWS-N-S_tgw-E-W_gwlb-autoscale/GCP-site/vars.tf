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
# GCP region
variable "region" {
  type    = string
  default = "europe-west4" #Default Region
}
# GCP zone
variable "zone" {
  type    = string
  default = "europe-west4-a" #Default Zone
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
