locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  region = "europe-west2"
  zone1  = "europe-west2-a"
  zone2  = "europe-west2-a"
  prefix = "demo-fgt-sdn-fnac"

  prefix_1 = "es"
  prefix_2 = "pt"
  #-----------------------------------------------------------------------------------------------------
  # VPC variables
  #-----------------------------------------------------------------------------------------------------
  # (Update any VPC name with existing VPC)
  vpc_names = {
    mgmt    = google_compute_network.fgt_vpc_mgmt.name
    public  = google_compute_network.fgt_vpc_public.name   
    private = google_compute_network.fgt_vpc_private.name
  }
  vpc_self_link = {
    mgmt    = google_compute_network.fgt_vpc_mgmt.self_link
    public  = google_compute_network.fgt_vpc_public.self_link   
    private = google_compute_network.fgt_vpc_private.self_link
  }
  # (CIRDs ranges of existing VPC or customize to deploy)
  subnet_cidrs = {
    mgmt    = "172.31.200.0/24"
    public  = "192.168.60.0/24"
    private = "10.1.0.0/24"
  }
  # (Update any subnet name with existing subnet in existing VPC)
  subnet_names = {
    mgmt    = google_compute_subnetwork.fgt_subnet_mgmt.name
    public  = google_compute_subnetwork.fgt_subnet_public.name 
    private = google_compute_subnetwork.fgt_subnet_private.name
  }
  # (Used to create different routes with different priority)
  private_route_cidrs_default   = ["0.0.0.0/0"]
  private_route_cidrs_rfc1918   = ["172.16.0.0/12", "10.0.0.0/8", "192.168.0.0/16"]
  priority_default              = 500
  priority_rfc1918              = 100
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  license_type   = "byol"
  license_file_1 = "./licenses/license1.lic"
  license_file_2 = "./licenses/license2.lic"

  machine = "n1-standard-4"

  admin_port = "8443"
  admin_cidr = "0.0.0.0/0"

  cluster_type = "fgcp"
  fgt_passive  = true
  #-----------------------------------------------------------------------------------------------------
  # VPC spokes peered to VPC private
  #-----------------------------------------------------------------------------------------------------
  vpc-spoke_cidrs_1 = ["10.1.1.0/24"]
  vpc-spoke_cidrs_2 = ["10.1.2.0/24"]
}