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

# list of subnet to create vm
variable "subnet_name" {
  type = string
  default = null
}

# VM test Image name
variable "image-vm" {
  type    = string
  default = "debian-cloud/debian-11"
}

// SSH RSA public key for KeyPair if not exists
variable "ssh-keys" {
  type    = string
  default = null
}

# GCP instance machine type for testing vm
variable "machine_type" {
  type    = string
  default = "e2-small"
}

# SSH RSA public key for KeyPair if not exists
variable "rsa-public-key" {
  type    = string
  default = null
}

# GCP user name launch Terrafrom
variable "gcp-user_name" {
  type    = string
  default = null
}

# Tags
variable "tags" {
  type    = list(string)
  default = ["tag-default"]
}
