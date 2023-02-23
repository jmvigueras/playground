##############################################################################################################
# Terraform state
##############################################################################################################
terraform {
  required_version = ">= 0.12"
}

##############################################################################################################
# Deployment in AWS
##############################################################################################################
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = local.region["id"]
  # Uncomment if using AWS SSO:
  # token      = var.token
}

# Access and secret keys to your environment
variable "access_key" {}
variable "secret_key" {}