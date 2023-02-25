#------------------------------------------------------------------------------------------------------------
# Create FGT VPC
#------------------------------------------------------------------------------------------------------------
# Create MGMT-HA VPC
resource "google_compute_network" "vpc_mgmt" {
  name                    = "${local.prefix}-vpc-mgmt"
  auto_create_subnetworks = false
}
# Create public VPC
resource "google_compute_network" "vpc_public" {
  name                    = "${local.prefix}-vpc-public"
  auto_create_subnetworks = false
}
# Create private VPC
resource "google_compute_network" "vpc_private" {
  name                    = "${local.prefix}-vpc-private"
  auto_create_subnetworks = false
}
#------------------------------------------------------------------------------------------------------------
# Create FGT Subnets
#------------------------------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnet_mgmt" {
  name          = "${local.prefix}-subnet-mgmt"
  region        = local.region
  network       = google_compute_network.vpc_mgmt.name
  ip_cidr_range = local.subnet_cidrs["mgmt"]
}
resource "google_compute_subnetwork" "subnet_public" {
  name          = "${local.prefix}-subnet-public"
  region        = local.region
  network       = google_compute_network.vpc_public.name
  ip_cidr_range = local.subnet_cidrs["public"]
}
resource "google_compute_subnetwork" "subnet_private" {
  name          = "${local.prefix}-subnet-private"
  region        = local.region
  network       = google_compute_network.vpc_private.name
  ip_cidr_range = local.subnet_cidrs["private"]
}
#------------------------------------------------------------------------------------------------------------
# Create Private route to FGT
#------------------------------------------------------------------------------------------------------------
resource "google_compute_route" "private_route_to_fgt" {
  count        = length(local.private_route_cidrs)
  name         = "${local.prefix}-private-route-to-fgt-${count.index + 1}"
  dest_range   = local.private_route_cidrs[count.index]
  network      = google_compute_network.vpc_private.name
  next_hop_ilb = module.fgt_ips-nsg.fgt-active-ni_ips["private"]
  priority     = 100
}
#------------------------------------------------------------------------------------------------------------
# Create VPC spokes peered to VPC FGT
#------------------------------------------------------------------------------------------------------------
module "vpc_spoke" {
  source = "git::github.com/jmvigueras/modules//gcp/vpc-spoke"

  prefix = local.prefix
  region = local.region

  spoke-subnet_cidrs = local.vpc-spoke_cidrs
  fgt_vpc_self_link  = google_compute_network.vpc_private.self_link
}

#------------------------------------------------------------------------------------------------------------
# Create VM in VPC spokes
#------------------------------------------------------------------------------------------------------------
module "vm_spoke" {
  source = "git::github.com/jmvigueras/modules//gcp/new-instance"

  prefix = local.prefix
  region = local.region
  zone   = local.zone1

  rsa-public-key = trimspace(tls_private_key.ssh-rsa.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = module.vpc_spoke.subnet_name
}
