resource "google_compute_route" "route_private" {
  depends_on = [google_compute_subnetwork.subnet_private-pro]
  name        = "${var.prefix}-${var.c_id}-route-private"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.vpc-private.name
  next_hop_ip = cidrhost(cidrsubnet(var.vpc_cidr,5,16),10)
  priority    = 100
  tags         = ["${var.prefix}-${var.c_id}-route-vm-private"]
}

