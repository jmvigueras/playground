output "id" {
  value = google_compute_router.cloud_router.id
}

output "interface_names" {
    value = [google_compute_router_interface.cloud_router_nic_0.name, google_compute_router_interface.cloud_router_nic_1.name]
}
