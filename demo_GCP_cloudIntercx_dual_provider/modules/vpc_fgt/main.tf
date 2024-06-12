#------------------------------------------------------------------------------------------------------------
# Create VPCs Fortigate
# - VPC for MGMT and HA interface
# - VPC for Public interface
# - VPC for Private interface  
#------------------------------------------------------------------------------------------------------------
# Create MGMT-HA VPC
resource "google_compute_network" "vpc_mgmt" {
  name                    = "${var.prefix}-vpc-mgmt"
  auto_create_subnetworks = false
}
# Create public VPC
resource "google_compute_network" "vpc_public" {
  name                    = "${var.prefix}-vpc-public"
  auto_create_subnetworks = false
  //  routing_mode            = "GLOBAL"
}
# Create private VPC
resource "google_compute_network" "vpc_private" {
  name                    = "${var.prefix}-vpc-private"
  auto_create_subnetworks = false
  //  routing_mode            = "GLOBAL"
}

#------------------------------------------------------------------------------------------------------------
# Create subnets
# - VPC public: subnet_public, subnet_proxy
# - VPC private: subnet_private, subnet_bastion
# - VPC mgmt: subnet_mgmt
#------------------------------------------------------------------------------------------------------------
### Public Subnet ###
resource "google_compute_subnetwork" "subnet_public" {
  name          = "${var.prefix}-subnet-public"
  region        = var.region
  network       = google_compute_network.vpc_public.name
  ip_cidr_range = local.subnet_public_cidr
}
### Private Subnet ###
resource "google_compute_subnetwork" "subnet_private" {
  name          = "${var.prefix}-subnet-private"
  region        = var.region
  network       = google_compute_network.vpc_private.name
  ip_cidr_range = local.subnet_private_cidr
}
### Bastion Subnet ###
resource "google_compute_subnetwork" "subnet_bastion" {
  name          = "${var.prefix}-subnet-bastion"
  region        = var.region
  network       = google_compute_network.vpc_private.name
  ip_cidr_range = local.subnet_bastion_cidr
}
### HA MGMT SYNC Subnet ###
resource "google_compute_subnetwork" "subnet_mgmt" {
  name                     = "${var.prefix}-subnet-mgmt"
  region                   = var.region
  network                  = google_compute_network.vpc_mgmt.name
  ip_cidr_range            = local.subnet_mgmt_cidr
  private_ip_google_access = true
}

#------------------------------------------------------------------------------------------------------------
# Create firewalls rules
#------------------------------------------------------------------------------------------------------------
# Firewall Rule External MGMT
resource "google_compute_firewall" "allow-mgmt-fgt" {
  name    = "${var.prefix}-allow-mgmt-fgt"
  network = google_compute_network.vpc_mgmt.name

  allow {
    protocol = "all"
  }

  source_ranges = [var.admin_cidr]
  target_tags   = ["${var.prefix}-subnet-mgmt-t-fwr"]
}

# Firewall Rule External PUBLIC
resource "google_compute_firewall" "allow-public-fgt" {
  name    = "${var.prefix}-allow-public-fgt"
  network = google_compute_network.vpc_public.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-subnet-public-t-fwr"]
}

# Firewall Rule Internal FGT PRIVATE
resource "google_compute_firewall" "allow-private-fgt" {
  name    = "${var.prefix}-allow-private-fgt"
  network = google_compute_network.vpc_private.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-subnet-private-t-fwr"]
}

# Firewall Rule Internal Bastion
resource "google_compute_firewall" "allow-bastion-vm" {
  name    = "${var.prefix}-allow-bastion-vm"
  network = google_compute_network.vpc_private.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-subnet-bastion-t-fwr"]
}
