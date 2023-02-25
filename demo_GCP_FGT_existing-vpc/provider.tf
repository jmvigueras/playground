### GCP terraform for HA setup
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.48.0"
    }
  }
}
provider "google" {
  project      = var.project
  region       = var.region
  zone         = var.zone1
  access_token = var.token
}
provider "google-beta" {
  project      = var.project
  region       = var.region
  zone         = var.zone1
  access_token = var.token
}

# GCP resourcers prefix description
variable "project" {
  type    = string
  default = null
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

variable "token" {
  type    = string
  default = null
}