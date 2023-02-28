# Firewall Rule AllowAll
resource "google_compute_firewall" "allow-vpc-mgmt-ha" {
  name    = "${var.prefix}-${var.c_id}-vpc-mgmt-ha-allow-all"
  network = google_compute_network.vpc-mgmt-ha.name
  
  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.c_id}-fwr-vpc-mgmt-ha-allow-all"]
}

resource "google_compute_firewall" "allow-vpc-ic-1" {
  name    = "${var.prefix}-${var.c_id}-vpc-ic-1-allow-all"
  network = google_compute_network.vpc-ic-1.name
  
  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.c_id}-fwr-vpc-ic-1-allow-all"]
}

resource "google_compute_firewall" "allow-vpc-ic-2" {
  name    = "${var.prefix}-${var.c_id}-vpc-ic-2-allow-all"
  network = google_compute_network.vpc-ic-2.name
  
  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.c_id}-fwr-vpc-ic-2-allow-all"]
}

resource "google_compute_firewall" "allow-vpc-private" {
  name    = "${var.prefix}-${var.c_id}-vpc-private-allow-all"
  network = google_compute_network.vpc-private.name
  
  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-${var.c_id}-fwr-private-allow-all"]
}


