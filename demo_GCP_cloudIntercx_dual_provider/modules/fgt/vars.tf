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
variable "zone1" {
  type    = string
  default = "europe-west4-a" #Default Zone
}

# GCP zone
variable "zone2" {
  type    = string
  default = "europe-west4-a" #Default Zone
}

# GCP instance machine type
variable "machine" {
  type    = string
  default = "n1-standard-4"
}

# license file for active
variable "licenseFile" {
  type    = string
  default = "license1.lic"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  default = "payg"
}

// license file for the active fgt
variable "license_file" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./licenses/license1.lic"
}

variable "fgt_version" {
  type    = string
  default = "726"
}
variable "fgt_config" {
  type    = string
  default = ""
}

// SSH RSA public key for KeyPair if not exists
variable "rsa-public-key" {
  type    = string
  default = null
}

// GCP user name launch Terrafrom
variable "gcp-user_name" {
  type    = string
  default = null
}

variable "fgt-ni_ips" {
  type    = map(string)
  default = null
}

variable "alias_ip_ranges" {
  type    = map(string)
  default = {}
}

variable "subnet_names" {
  type    = map(string)
  default = null
}