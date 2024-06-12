#------------------------------------------------------------------------------------------------------------
# Create VPC SPOKE 
# - Create VPC
# - Create Subnet
# - Create Peering to private VPC
# - Firewalls rules
#------------------------------------------------------------------------------------------------------------
locals {
  vpc_name    = var.prefix 
  subnet_name = "${var.prefix}-subnet-vm"
}

# Create SPOKE VPC
resource "google_compute_network" "vpc_spoke" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
}
## Spoke Subnet ##
resource "google_compute_subnetwork" "subnet_spoke" {
  name          = local.subnet_name
  region        = var.region
  network       = google_compute_network.vpc_spoke.name
  ip_cidr_range = var.spoke-subnet_cidr
}
## Spoke peering to VPC private ##
resource "google_compute_network_peering" "vpc_spoke_peer-to-private_1" {
  name                 = "${var.prefix}-peer-spoke-to-private-1"
  network              = var.fgt_vpc_self_link
  peer_network         = google_compute_network.vpc_spoke.self_link
  export_custom_routes = true
}

resource "google_compute_network_peering" "vpc_spoke_peer-to-private_2" {
  name                 = "${var.prefix}-peer-spoke-to-private-2"
  network              = google_compute_network.vpc_spoke.self_link
  peer_network         = var.fgt_vpc_self_link
  import_custom_routes = true
}
# Firewall Rule Internal Bastion
resource "google_compute_firewall" "vpc_spoke_fw_allow-all" {
  name    = "${google_compute_network.vpc_spoke.name}-subnet-fwr-allow-all"
  network = google_compute_network.vpc_spoke.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = concat(["${local.subnet_name}-t-route"], ["${local.subnet_name}-t-fwr"], var.tags)
}

