output "vpc_name" {
  value = google_compute_network.vpc_spoke.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet_spoke.name
}

output "fwr_tag" {
  value = google_compute_firewall.vpc_spoke_fw_allow-all.target_tags
}