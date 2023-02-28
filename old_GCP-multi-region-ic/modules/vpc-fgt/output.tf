# Output
output "subnet_names" {
  value = {
    mgmt-ha-r1        = google_compute_subnetwork.subnet_mgmt-ha-r1.name
    mgmt-ha-r2        = google_compute_subnetwork.subnet_mgmt-ha-r2.name
    ic-1-s1           = google_compute_subnetwork.subnet_ic-1-s1.name
    ic-1-s2           = google_compute_subnetwork.subnet_ic-1-s2.name
    ic-2-s1           = google_compute_subnetwork.subnet_ic-2-s1.name
    ic-2-s2           = google_compute_subnetwork.subnet_ic-2-s2.name
    private-fgt-r1    = google_compute_subnetwork.subnet_private-fgt-r1.name
    private-fgt-r2    = google_compute_subnetwork.subnet_private-fgt-r2.name
    private-pro       = google_compute_subnetwork.subnet_private-pro.name
  }
}

# Output
output "subnet_cidrs" {
  value = {
    mgmt-ha-r1        = google_compute_subnetwork.subnet_mgmt-ha-r1.ip_cidr_range
    mgmt-ha-r2        = google_compute_subnetwork.subnet_mgmt-ha-r2.ip_cidr_range
    ic-1-s1           = google_compute_subnetwork.subnet_ic-1-s1.ip_cidr_range
    ic-1-s2           = google_compute_subnetwork.subnet_ic-1-s2.ip_cidr_range
    ic-2-s1           = google_compute_subnetwork.subnet_ic-2-s1.ip_cidr_range
    ic-2-s2           = google_compute_subnetwork.subnet_ic-2-s2.ip_cidr_range
    private-fgt-r1    = google_compute_subnetwork.subnet_private-fgt-r1.ip_cidr_range
    private-fgt-r2    = google_compute_subnetwork.subnet_private-fgt-r2.ip_cidr_range
    private-pro       = google_compute_subnetwork.subnet_private-pro.ip_cidr_range
  }
}

# Output
output "vpc_self_link" {
  value = {
    ic-1          = google_compute_network.vpc-ic-1.self_link
    ic-2          = google_compute_network.vpc-ic-2.self_link
  }
}

output "vpc_cidrs" {
  value = {
    ic-1          = cidrsubnet(var.vpc_cidr,3,2)
    ic-2          = cidrsubnet(var.vpc_cidr,3,3)
    private       = cidrsubnet(var.vpc_cidr,3,4)
  }
}


