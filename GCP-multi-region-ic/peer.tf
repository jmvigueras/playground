resource "google_compute_network_peering" "peer-ic-1-c1-to-c2-a" {
  name         = "${var.prefix}-peer-ic-1-c1-to-c2-a"
  network      = module.vpc-c2.vpc_self_link["ic-1"]
  peer_network = module.vpc-c1.vpc_self_link["ic-1"]
}

resource "google_compute_network_peering" "peer-ic-1-c1-to-c2-b" {
  name         = "${var.prefix}-peer-ic-1-c1-to-c2-b"
  network      = module.vpc-c1.vpc_self_link["ic-1"]
  peer_network = module.vpc-c2.vpc_self_link["ic-1"]
}

resource "google_compute_network_peering" "peer-ic-2-c1-to-c2-a" {
  name         = "${var.prefix}-peer-ic-2-c1-to-c2-a"
  network      = module.vpc-c2.vpc_self_link["ic-2"]
  peer_network = module.vpc-c1.vpc_self_link["ic-2"]
}

resource "google_compute_network_peering" "peer-ic-2-c1-to-c2-b" {
  name         = "${var.prefix}-peer-ic-2-c1-to-c2-b"
  network      = module.vpc-c1.vpc_self_link["ic-2"]
  peer_network = module.vpc-c2.vpc_self_link["ic-2"]
}