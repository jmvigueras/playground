##############################################################################################################
#
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment -
#
##############################################################################################################

# Access and secret keys to your environment
variable "access_key" {}
variable "secret_key" {}

# Uncomment if using AWS SSO:
# variable "token"      {}

# Prefix for all resources created for this deployment in AWS
variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "terraform"
}

# Tag project to add to resources
variable "tag-project" {
  description = "Attribute for tag Enviroment"
  default     = "auto-deploy-terraform"
}

variable "tags" {
  description = "Attribute for tag Enviroment"
  type        = map(any)
  default = {
    Project = "auto-deploy-terraform"
  }
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  default = "payg"
}

// CIDR range for ONPREM sites
variable "spokes-onprem-cidr" {
  default = "192.168.0.0/16"
}

// CIDR range for vpc-se
variable "vpc-sec_net" {
  default = "172.30.0.0/20"
}

// CPC spokes on AWS
variable "subnet-vpc-spoke" {
  type = map(string)
  default = {
    "spoke-1-vm" = "172.30.16.0/24"
    "spoke-2-vm" = "172.30.18.0/24"
  }
}

variable "region" {
  type = map(string)
  default = {
    "region"     = "eu-west-1"
    "region_az1" = "eu-west-1a"
    "region_az2" = "eu-west-1c"
  }
}

// SSH RSA public key for KeyPair if not exists
variable "rsa-public-key" {
  type    = string
  default = null
}

# References to your FortiGate
variable "fgt-ami" {
  description = "Provide an AMI for the FortiGate instances"
  default     = null
}

variable "fgt_build" {
  description = "FortiOS version build" 
  default     = "build1688" //7.2.9
}

variable "instance_type" {
  description = "Provide the instance type for the FortiGate instances"
  default     = "c6in.large"
}

variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  default     = null
}

variable "admin_cidr" {
  description = "Provide a network CIDR for accessing the FortiGate instances"
  default     = "0.0.0.0/0"
}

variable "admin-sport" {
  default = "8443"
}

// Fortigate interface probe port
variable "backend-probe_port" {
  type    = string
  default = "8008"
}