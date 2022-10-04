########### Network Related ########### 
############################################
### Create VPC
############################################
resource "google_compute_network" "vpc-mgmt-ha" {
  name                    = "${var.prefix}-${var.c_id}-vpc-mgmt-ha"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc-ic-1" {
  name                    = "${var.prefix}-${var.c_id}-vpc-ic-1"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc-ic-2" {
  name                    = "${var.prefix}-${var.c_id}-vpc-ic-2"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc-private" {
  name                    = "${var.prefix}-${var.c_id}-vpc-private"
  auto_create_subnetworks = false
}
############################################
### Create Subnets
############################################
### Mgmt-ha r1 ###
resource "google_compute_subnetwork" "subnet_mgmt-ha-r1" {
  name          = "${var.prefix}-${var.c_id}-subnet-mgmt-ha-r1"
  region        = var.region-1
  network       = google_compute_network.vpc-mgmt-ha.name
  ip_cidr_range = cidrsubnet(var.vpc_cidr,4,2)
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_mgmt-ha-r2" {
  name          = "${var.prefix}-${var.c_id}-subnet-mgmt-ha-r2"
  region        = var.region-2
  network       = google_compute_network.vpc-mgmt-ha.name
  ip_cidr_range = cidrsubnet(var.vpc_cidr,4,3)
  private_ip_google_access = true
}

### Public InterConnexion 1 ###
resource "google_compute_subnetwork" "subnet_ic-1-s1" {
  name                     = "${var.prefix}-${var.c_id}-subnet-ic-1-s1"
  region                   = var.region-1
  network                  = google_compute_network.vpc-ic-1.name
  ip_cidr_range            = cidrsubnet(var.vpc_cidr,5,8)
  private_ip_google_access = true
}
resource "google_compute_subnetwork" "subnet_ic-1-s2" {
  name                     = "${var.prefix}-${var.c_id}-subnet-ic-1-s2"
  region                   = var.region-2
  network                  = google_compute_network.vpc-ic-1.name
  ip_cidr_range            = cidrsubnet(var.vpc_cidr,5,9)
  private_ip_google_access = true
}

### Public InterConnexion 2 ###
resource "google_compute_subnetwork" "subnet_ic-2-s1" {
  name                     = "${var.prefix}-${var.c_id}-subnet-ic-2-s1"
  region                   = var.region-2
  network                  = google_compute_network.vpc-ic-2.name
  ip_cidr_range            = cidrsubnet(var.vpc_cidr,5,12)
  private_ip_google_access = true
}
resource "google_compute_subnetwork" "subnet_ic-2-s2" {
  name                     = "${var.prefix}-${var.c_id}-subnet-ic-2-s2"
  region                   = var.region-1
  network                  = google_compute_network.vpc-ic-2.name
  ip_cidr_range            = cidrsubnet(var.vpc_cidr,5,13)
  private_ip_google_access = true
}

### Private Subnet fgt ###
resource "google_compute_subnetwork" "subnet_private-fgt-r1" {
  name          = "${var.prefix}-${var.c_id}-subnet-private-fgt-r1"
  region        = var.region-1
  network       = google_compute_network.vpc-private.name
  ip_cidr_range = cidrsubnet(var.vpc_cidr,5,16)
}
resource "google_compute_subnetwork" "subnet_private-fgt-r2" {
  name          = "${var.prefix}-${var.c_id}-subnet-private-fgt-r2"
  region        = var.region-2
  network       = google_compute_network.vpc-private.name
  ip_cidr_range = cidrsubnet(var.vpc_cidr,5,17)
}

### Private Subnet pro ###
resource "google_compute_subnetwork" "subnet_private-pro" {
  name          = "${var.prefix}-${var.c_id}-subnet-private-pro"
  region        = var.region-1
  network       = google_compute_network.vpc-private.name
  ip_cidr_range = cidrsubnet(var.vpc_cidr,5,18)
}


