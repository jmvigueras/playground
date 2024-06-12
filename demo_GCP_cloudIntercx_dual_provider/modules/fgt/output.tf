output "fgt_id" {
  value = google_compute_instance.fgt.instance_id
}

output "fgt_self_link" {
  value = google_compute_instance.fgt.self_link
}

output "fgt_eip_public" {
  value = google_compute_address.public-ip.address
}
