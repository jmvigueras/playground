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
output "vm-test_public-ip" {
  //value = "${split("@", data.google_client_openid_userinfo.me.email)[0]}@${google_compute_instance.vm-test.network_interface.0.access_config.0.nat_ip}"
  value = "jvigueras@${google_compute_instance.vm-test.network_interface.0.access_config.0.nat_ip}"
}

output "vm-test_private-ip" {
  value = google_compute_instance.vm-test.network_interface.0.network_ip
}