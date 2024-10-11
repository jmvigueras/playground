# GCP resourcers prefix description
variable "prefix" {
  type    = string
  default = "terraform"
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

# Site id
variable "site_id" {
  type    = string
  default = "1"
}

# FortiGate Image name
variable "image" {
  type    = string
  default = "/projects/fortigcp-project-001/global/images/fortinet-fgtondemand-729-20240816-001-w-license" //v7.2.9
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
variable "ssh-keys" {
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
