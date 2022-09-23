resource "google_compute_route" "spoke1-route" {
  name        = "${var.prefix}-spoke1-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.vpc-spoke1.name
  next_hop_ip = cidrhost(cidrsubnet(var.vpc-site_net,4,4),10)
  priority    = 100
  depends_on  = [google_compute_subnetwork.spoke1-subnet]
  tags         = ["${var.prefix}-t-route-vm-spoke1"]
}

resource "google_compute_route" "private-route" {
  name        = "${var.prefix}-private-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.vpc-private.name
  next_hop_ip = cidrhost(cidrsubnet(var.vpc-site_net,4,3),10)
  priority    = 100
  depends_on  = [google_compute_subnetwork.private-subnet]
  tags         = ["${var.prefix}-t-route-vm-private"]
}
