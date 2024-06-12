resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "${var.prefix}-vpn-${var.suffix}"
  network = var.vpc_id
}

resource "google_compute_address" "vpn_static_ip" {
  count = var.vpn_static_ip != null ? 0 : 1

  name = "${var.prefix}-vpn-static-ip-${var.suffix}"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "${var.prefix}-fr-esp"
  ip_protocol = "ESP"
  ip_address  = var.vpn_static_ip != null ? var.vpn_static_ip : one(google_compute_address.vpn_static_ip).address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "${var.prefix}-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "${var.prefix}-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name          = "${var.prefix}-tunnel1"

  peer_ip                 = var.peer_ip
  shared_secret           = var.vpn_psk
  ike_version             = var.ike_version            
  local_traffic_selector  = var.local_traffic_selector
  remote_traffic_selector = var.remote_traffic_selector

  target_vpn_gateway = google_compute_vpn_gateway.target_gateway.id

  router = var.router_self_link

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

/*
resource "google_compute_route" "route1" {
  name       = "route1"
  network    = google_compute_network.network1.name
  dest_range = "15.0.0.0/24"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id
}
*/