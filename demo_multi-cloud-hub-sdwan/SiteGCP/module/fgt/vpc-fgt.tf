########### Network Related ########### 
### VPC ###
resource "google_compute_network" "vpc-mgmt" {
  name                    = "${var.prefix}-${var.site_id}-vpc-mgmt"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc-public" {
  name                    = "${var.prefix}-${var.site_id}-vpc-public"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc-private" {
  name                    = "${var.prefix}-${var.site_id}-vpc-private"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc-spoke1" {
  name                    = "${var.prefix}-${var.site_id}-vpc-spoke1"
  auto_create_subnetworks = false
}

### HA MGMT SYNC Subnet ###
resource "google_compute_subnetwork" "mgmt-subnet" {
  name                     = "${var.prefix}-${var.site_id}-mgmt-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc-mgmt.name
  ip_cidr_range            = cidrsubnet(var.vpc-site_net, 4, 1)
  private_ip_google_access = true
}
### Public Subnet ###
resource "google_compute_subnetwork" "public-subnet" {
  name          = "${var.prefix}-${var.site_id}-public-subnet"
  region        = var.region
  network       = google_compute_network.vpc-public.name
  ip_cidr_range = cidrsubnet(var.vpc-site_net, 4, 2)
}
### Private Subnet ###
resource "google_compute_subnetwork" "private-subnet" {
  name          = "${var.prefix}-${var.site_id}-private-subnet"
  region        = var.region
  network       = google_compute_network.vpc-private.name
  ip_cidr_range = cidrsubnet(var.vpc-site_net, 4, 3)
}
### Spoke1 Subnet ###
resource "google_compute_subnetwork" "spoke1-subnet" {
  name          = "${var.prefix}-${var.site_id}-spoke1-subnet"
  region        = var.region
  network       = google_compute_network.vpc-spoke1.name
  ip_cidr_range = cidrsubnet(var.vpc-site_net, 4, 4)
}