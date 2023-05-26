# Create health checks
resource "google_compute_region_health_check" "ilb_private_health-check_fgt" {
  name               = "${var.prefix}-ilb-private-fgt-health-check-${var.suffix}"
  region             = var.region
  check_interval_sec = 2
  timeout_sec        = 2

  tcp_health_check {
    port = var.backend-probe_port
  }
}
# Create FGT active instance group
resource "google_compute_instance_group" "lb_group_fgt-1" {
  name      = "${var.prefix}-lb-group-fgt-1"
  zone      = var.zone1
  instances = [var.fgt_active_self_link]
}
# Create FGT passive instance group
resource "google_compute_instance_group" "lb_group_fgt-2" {
  name      = "${var.prefix}-lb-group-fgt-2"
  zone      = var.zone2
  instances = [var.fgt_passive_self_link]
}
#------------------------------------------------------------------------------------------------------------
# Create iLB
#------------------------------------------------------------------------------------------------------------
# Create Internal Load Balancer Zone1
resource "google_compute_region_backend_service" "ilb_private_zone1" {
  provider = google-beta
  name     = "${var.prefix}-ilb-fgt-zone1"
  region   = var.region
  network  = var.vpc_names["private"]

  backend {
    group = google_compute_instance_group.lb_group_fgt-1.id
  }
  backend {
    group = google_compute_instance_group.lb_group_fgt-2.id
  }

  health_checks = [google_compute_region_health_check.ilb_private_health-check_fgt.id]
  connection_tracking_policy {
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
}
# Create Internal Load Balancer Zone2
resource "google_compute_region_backend_service" "ilb_private_zone2" {
  provider = google-beta
  name     = "${var.prefix}-ilb-fgt-zone2"
  region   = var.region
  network  = var.vpc_names["private"]

  backend {
    group = google_compute_instance_group.lb_group_fgt-1.id
  }
  backend {
    group = google_compute_instance_group.lb_group_fgt-2.id
  }

  health_checks = [google_compute_region_health_check.ilb_private_health-check_fgt.id]
  connection_tracking_policy {
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
}
# Create forwarding rule to ILB in private VPC Zone1
resource "google_compute_forwarding_rule" "ilb_private_fwd-rule_zone1" {
  name   = "${var.prefix}-ilb-fwd-rule-zone1"
  region = var.region

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb_private_zone1.id
  all_ports             = true
  network               = var.vpc_names["private"]
  subnetwork            = var.subnet_names["private"]
  allow_global_access   = true
  ip_address            = var.ilb_ip_private_1
}
# Create forwarding rule to ILB in private VPC Zone2
resource "google_compute_forwarding_rule" "ilb_private_fwd-rule_zone2" {
  name   = "${var.prefix}-ilb-fwd-rule-zone2"
  region = var.region

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb_private_zone2.id
  all_ports             = true
  network               = var.vpc_names["private"]
  subnetwork            = var.subnet_names["private"]
  allow_global_access   = true
  ip_address            = var.ilb_ip_private_2
}