output "vpc_names" {
  description = "Map of VPC names"
  value = {
    mgmt    = google_compute_network.vpc_mgmt.name
    public  = google_compute_network.vpc_public.name
    private = google_compute_network.vpc_private.name
  }
}

output "vpc_self_links" {
  description = "Map of VPC SelfLink"
  value = {
    mgmt    = google_compute_network.vpc_mgmt.self_link
    public  = google_compute_network.vpc_public.self_link
    private = google_compute_network.vpc_private.self_link
  }
}

output "vpc_ids" {
  description = "Map of VPC IDs"
  value = {
    mgmt    = google_compute_network.vpc_mgmt.id
    public  = google_compute_network.vpc_public.id
    private = google_compute_network.vpc_private.id
  }
}

output "subnet_names" {
  description = "List of subnets names"
  value = {
    mgmt    = google_compute_subnetwork.subnet_mgmt.name
    public  = google_compute_subnetwork.subnet_public.name
    private = google_compute_subnetwork.subnet_private.name
    bastion = google_compute_subnetwork.subnet_bastion.name
  }
}

output "subnet_self_links" {
  description = "List of subnets SelfLink"
  value = {
    mgmt    = google_compute_subnetwork.subnet_mgmt.self_link
    public  = google_compute_subnetwork.subnet_public.self_link
    private = google_compute_subnetwork.subnet_private.self_link
    bastion = google_compute_subnetwork.subnet_bastion.self_link
  }
}

output "subnet_ids" {
  description = "List of subnets IDs"
  value = {
    mgmt    = google_compute_subnetwork.subnet_mgmt.id
    public  = google_compute_subnetwork.subnet_public.id
    private = google_compute_subnetwork.subnet_private.id
    bastion = google_compute_subnetwork.subnet_bastion.id
  }
}

output "subnet_cidrs" {
  description = "List of subnets CIDRs"
  value = {
    public  = local.subnet_public_cidr
    private = local.subnet_private_cidr
    bastion = local.subnet_bastion_cidr
    mgmt    = local.subnet_mgmt_cidr
  }
}

output "fgt-active-ni_ips" {
  description = "Fortigate instance cluster member 1 map of IPs"
  value = {
    public  = local.fgt-1_ni_public_ip
    private = local.fgt-1_ni_private_ip
    mgmt    = local.fgt-1_ni_mgmt_ip
  }
}

output "fgt-passive-ni_ips" {
  description = "Fortigate instance cluster member 2 map of IPs"
  value = {
    public  = local.fgt-2_ni_public_ip
    private = local.fgt-2_ni_private_ip
    mgmt    = local.fgt-2_ni_mgmt_ip
  }
}