#------------------------------------------------------------------------------------------------------------
# Create FGT VPC (comment if any VPC already exists)
#------------------------------------------------------------------------------------------------------------
# Create public VPC
resource "google_compute_network" "fgt_vpc_public" {
  name                    = "${local.prefix}-vpc-public"
  auto_create_subnetworks = false
}
# Create MGMT-HA VPC
resource "google_compute_network" "fgt_vpc_mgmt" {
  name                    = "${local.prefix}-vpc-mgmt"
  auto_create_subnetworks = false
}
# Create private VPC
resource "google_compute_network" "fgt_vpc_private" {
  name                    = "${local.prefix}-vpc-private"
  auto_create_subnetworks = false
}
#------------------------------------------------------------------------------------------------------------
# Create public IP for FGT cluster FGCP
#------------------------------------------------------------------------------------------------------------
resource "google_compute_address" "cluster-public-ip" {
  count        = local.cluster_type == "fgcp" ? 1 : 0
  name         = "${var.prefix}-cluster-public-ip"
  address_type = "EXTERNAL"
  region       = var.region
}
#------------------------------------------------------------------------------------------------------------
# Create FGT Subnets (comment if any subnet in VPC already exists)
#------------------------------------------------------------------------------------------------------------
# Create subnet in VPC public
resource "google_compute_subnetwork" "fgt_subnet_public" {
  name          = "${local.prefix}-subnet-public"
  region        = local.region
  network       = google_compute_network.fgt_vpc_public.name
  ip_cidr_range = local.subnet_cidrs["public"]
}
resource "google_compute_subnetwork" "fgt_subnet_mgmt" {
  name          = "${local.prefix}-subnet-mgmt"
  region        = local.region
  network       = google_compute_network.fgt_vpc_mgmt.name
  ip_cidr_range = local.subnet_cidrs["mgmt"]
}
resource "google_compute_subnetwork" "fgt_subnet_private" {
  name          = "${local.prefix}-subnet-private"
  region        = local.region
  network       = google_compute_network.fgt_vpc_private.name
  ip_cidr_range = local.subnet_cidrs["private"]
}
#------------------------------------------------------------------------------------------------------------
# Create private routes in VPC private
#------------------------------------------------------------------------------------------------------------
resource "google_compute_route" "private_route_to_fgt_default" {
  // depends_on   = [google_compute_subnetwork.fgt_subnet_private]
  count       = length(local.private_route_cidrs_default)
  name        = "${local.prefix}-private-route-default-to-fgt-${count.index + 1}"
  dest_range  = local.private_route_cidrs_default[count.index]
  network     = local.vpc_names["private"]
  next_hop_ip = module.fgt_ips-fwr.fgt-active-ni_ips["private"]
  priority    = local.priority_default
}
resource "google_compute_route" "private_route_to_fgt_rfc1918" {
  // depends_on   = [google_compute_subnetwork.fgt_subnet_private]
  count       = length(local.private_route_cidrs_rfc1918)
  name        = "${local.prefix}-private-route-rfc1918-to-fgt-${count.index + 1}"
  dest_range  = local.private_route_cidrs_rfc1918[count.index]
  network     = local.vpc_names["private"]
  next_hop_ip = module.fgt_ips-fwr.fgt-active-ni_ips["private"]
  priority    = local.priority_rfc1918
}
#------------------------------------------------------------------------------------------------------------
# Create VPC spokes peered to VPC FGT
#------------------------------------------------------------------------------------------------------------
module "vpc_spoke_1" {
  source = "git::github.com/jmvigueras/modules//gcp/vpc-spoke"

  prefix = "${local.prefix}-${local.prefix_1}"
  region = local.region

  spoke-subnet_cidrs = local.vpc-spoke_cidrs_es
  fgt_vpc_self_link  = local.vpc_self_link["private"]
}
module "vpc_spoke_2" {
  source = "git::github.com/jmvigueras/modules//gcp/vpc-spoke"

  prefix = "${local.prefix}-${local.prefix_2}"
  region = local.region

  spoke-subnet_cidrs = local.vpc-spoke_cidrs_pt
  fgt_vpc_self_link  = local.vpc_self_link["private"]
}
#------------------------------------------------------------------------------------------------------------
# Create VM in VPC spokes
#------------------------------------------------------------------------------------------------------------
module "vm_spoke_1" {
  source = "git::github.com/jmvigueras/modules//gcp/new-instance"

  prefix = "${local.prefix}-${local.prefix_1}"
  region = local.region
  zone   = local.zone1

  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = module.vpc_spoke_1.subnet_name
}
module "vm_spoke_2" {
  source = "git::github.com/jmvigueras/modules//gcp/new-instance"

  prefix = "${local.prefix}-${local.prefix_2}"
  region = local.region
  zone   = local.zone1

  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = module.vpc_spoke_2.subnet_name
}
