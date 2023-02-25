locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  region = "europe-west2"
  zone1  = "europe-west2-a"
  zone2  = "europe-west2-a"
  prefix = "demo-fgt-sdn"
  #-----------------------------------------------------------------------------------------------------
  # VPC variables
  #-----------------------------------------------------------------------------------------------------
  vpc_names = {
    mgmt    = google_compute_network.vpc_mgmt.name
    public  = google_compute_network.vpc_public.name
    private = google_compute_network.vpc_private.name
  }
  subnet_cidrs = {
    mgmt    = "172.31.200.0/24"
    public  = "192.168.60.0/24"
    private = "10.1.0.0/24"
  }
  subnet_names = {
    mgmt    = google_compute_subnetwork.subnet_mgmt.name
    public  = google_compute_subnetwork.subnet_public.name
    private = google_compute_subnetwork.subnet_private.name
  }
  private_route_cidrs = ["172.16.0.0/12", "10.0.0.0/8", "192.168.0.0/16"]
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  license_type   = "byol"
  license_file_1 = "./licensees/license1.lic"
  license_file_2 = "./licensees/license2.lic"

  machine = "n1-standard-4"

  admin_port = "8443"
  admin_cidr = "0.0.0.0/0"

  fgt_passive = true
  #-----------------------------------------------------------------------------------------------------
  # VPC spokes peered to VPC private
  #-----------------------------------------------------------------------------------------------------
  vpc-spoke_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}