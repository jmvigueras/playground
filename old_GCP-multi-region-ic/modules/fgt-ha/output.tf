# Output
output "FortiGate-HA-Master-MGMT-IP" {
  value = "https://${google_compute_instance.fgt-active.network_interface.0.access_config.0.nat_ip}:${var.adminsport}"
}
output "FortiGate-HA-Slave-MGMT-IP" {
  value = "https://${google_compute_instance.fgt-passive.network_interface.0.access_config.0.nat_ip}:${var.adminsport}"
}
output "FortiGate-Username" {
  value = "admin"
}
output "FortiGate-Password" {
  value = google_compute_instance.fgt-active.instance_id
}





