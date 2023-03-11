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

/*
provider "google_project_es" {
  project      = google_project.project_es.name
  region       = var.region_es
  zone         = var.zone1_es
  access_token = var.token_es
}

resource "google_project" "project_es" {
  name       = "fnac-project-es"
  project_id = "fnac-project-es"
  folder_id  = "local.folder_es"
}
*/

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