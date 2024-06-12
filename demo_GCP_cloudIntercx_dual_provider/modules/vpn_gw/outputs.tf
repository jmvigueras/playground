output "vpn_ip_address" {
  value = google_compute_address.vpn_static_ip.address
}