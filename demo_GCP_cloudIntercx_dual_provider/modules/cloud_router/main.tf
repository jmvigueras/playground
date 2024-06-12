#------------------------------------------------------------------------------------------------------------
# Create Cloud router in VPC
#------------------------------------------------------------------------------------------------------------
// Create cloud router
resource "google_compute_router" "cloud_router" {
  name    = "${var.prefix}-cloud-router"
  network = var.vpc_name
  region  = var.region
  
  bgp {
    asn = var.bgp_asn
  }
}
// Create cloud router interfaces (reduntant interfaces)
resource "google_compute_router_interface" "cloud_router_nic_0" {
  name                = "nic-0"
  region              = var.region
  router              = google_compute_router.cloud_router.name
  subnetwork          = var.subnet_self_link
  private_ip_address  = var.cloud_router_ips[0]
  redundant_interface = google_compute_router_interface.cloud_router_nic_1.name
}
resource "google_compute_router_interface" "cloud_router_nic_1" {
  name               = "nic-1"
  region             = var.region
  router             = google_compute_router.cloud_router.name
  subnetwork         = var.subnet_self_link
  private_ip_address = var.cloud_router_ips[1]
}

#------------------------------------------------------------------------------------------------------------
# Create Cloud router BGP peers
#------------------------------------------------------------------------------------------------------------
// Create fortigate BGP peer to Cloud Router Router Appliance
resource "google_compute_router_peer" "cloud_router_peer_1" {
  name                      = "${var.prefix}-router-peer-1"
  region                    = var.region
  router                    = google_compute_router.cloud_router.name
  interface                 = google_compute_router_interface.cloud_router_nic_0.name
  router_appliance_instance = var.fgt_self_link
  peer_asn                  = var.fgt_bgp_asn
  peer_ip_address           = var.fgt_ip
}
resource "google_compute_router_peer" "cloud_router_peer_2" {
  name                      = "${var.prefix}-router-peer-2"
  region                    = var.region
  router                    = google_compute_router.cloud_router.name
  interface                 = google_compute_router_interface.cloud_router_nic_1.name
  router_appliance_instance = var.fgt_self_link
  peer_asn                  = var.fgt_bgp_asn
  peer_ip_address           = var.fgt_ip
}