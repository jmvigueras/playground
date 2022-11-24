# Firewall Rule External MGMT
resource "google_compute_firewall" "allow-mgmt-fgt" {
  name    = "${var.prefix}-${var.site_id}-allow-mgmt-fgt"
  network = google_compute_network.vpc-mgmt.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "${var.admin_port}"]
  }

  allow {
    protocol = "udp"
    ports    = ["500", "4500", "4789"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.site_id}-t-fwr-ftg-mgmt"]
}

# Firewall Rule External PUBLIC
resource "google_compute_firewall" "allow-public-fgt" {
  name    = "${var.prefix}-${var.site_id}-allow-public-fgt"
  network = google_compute_network.vpc-public.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.site_id}-t-fwr-fgt-public"]
}

# Firewall Rule Internal FGT PRIVATE
resource "google_compute_firewall" "allow-private-fgt" {
  name    = "${var.prefix}-${var.site_id}-allow-private-fgt"
  network = google_compute_network.vpc-private.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.site_id}-t-fwr-fgt-private"]
}

# Firewall Rule Internal FGT SPOKE1
resource "google_compute_firewall" "allow-spoke1-fgt" {
  name    = "${var.prefix}-${var.site_id}-allow-spoke1-fgt"
  network = google_compute_network.vpc-spoke1.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.site_id}-t-fwr-fgt-spoke1"]
}


# Firewall Rule Internal SPOKE1
resource "google_compute_firewall" "allow-spoke1-vm" {
  name    = "${var.prefix}-${var.site_id}-allow-spoke1-vm"
  network = google_compute_network.vpc-spoke1.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.site_id}-t-fwr-vm-spoke1"]
}