# Output
output "fgt-site_mgmt-url" {
  value = "https://${google_compute_instance.fgt-site.network_interface.0.access_config.0.nat_ip}:${var.admin_port}"
}
output "username" {
  value = "admin"
}
output "password" {
  value = google_compute_instance.fgt-site.instance_id
}