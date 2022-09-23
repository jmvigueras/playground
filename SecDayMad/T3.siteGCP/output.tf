# Output
output "FortiGate-Public-IP" {
  value = google_compute_instance.fgt-site.network_interface.1.access_config.0.nat_ip
}
output "FortiGate-MGMT-IP" {
  value = "https://${google_compute_instance.fgt-site.network_interface.0.access_config.0.nat_ip}:${var.admin_port}"
}
output "FortiGate-Username" {
  value = "admin"
}
output "FortiGate-Password" {
  value = google_compute_instance.fgt-site.instance_id
}