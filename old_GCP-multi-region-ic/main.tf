# Create new random API key to be provisioned in FortiGates.
resource "random_string" "ipsec-psk-key" {
  length                 = 30
  special                = false
  numeric                = true
}

resource "random_string" "api-key" {
  length                 = 30
  special                = false
  numeric                = true
}

data "google_compute_image" "fgt_image" {
  project         = "fortigcp-project-001"
  family          = var.image_name == null ? var.image_family : null
  name            = var.image_name
}

#########################################
# Create VPCs
#########################################
module "vpc-c1" {
    source   =  "./modules/vpc-fgt"

    prefix      = var.prefix
    vpc_cidr    = "172.16.0.0/21"
    c_id        = var.c1_id 

    region-1    = var.region-1
    region-2    = var.region-2
}

module "vpc-c2" {
    source   =  "./modules/vpc-fgt"

    prefix      = var.prefix
    vpc_cidr    = "172.17.0.0/21"
    c_id        = var.c2_id

    region-1    = var.region-1
    region-2    = var.region-2
}

#########################################
# Create FGTs
#########################################
module "fgt-c1" {
    source   =  "./modules/fgt-ha"

    image           = data.google_compute_image.fgt_image.self_link
    prefix          = var.prefix
    c_id            = var.c1_id

    region-1        = var.region-1
    region-2        = var.region-2
    region-1_zone   = var.region-1_zone
    region-2_zone   = var.region-2_zone

    subnet_names        = module.vpc-c1.subnet_names
    subnet_cidrs        = module.vpc-c1.subnet_cidrs

    ipsec-psk-key       = random_string.ipsec-psk-key.result
    api-key             = random_string.api-key.result
    admin-cidr          = var.admin-cidr

    ic-peer_cidrs = {
        ic-1          = module.vpc-c2.vpc_cidrs["ic-1"]
        ic-2          = module.vpc-c2.vpc_cidrs["ic-2"]
        ic-pro        = module.vpc-c2.subnet_cidrs["private-pro"]
    }

    ic-peer_ips = {
        ic-1          = cidrhost(module.vpc-c2.subnet_cidrs["ic-1-s1"],10)
        ic-2          = cidrhost(module.vpc-c2.subnet_cidrs["ic-2-s2"],10)
        ic-hck        = cidrhost(module.vpc-c2.subnet_cidrs["private-pro"],15)
    }
    ipsec_ips = {
        local-1       = "10.0.10.1"
        peer-1        = "10.0.10.2"
        local-2       = "10.0.20.1"
        peer-2        = "10.0.20.2"
    }
}

module "fgt-c2" {
    source   =  "./modules/fgt-ha"

    image           = data.google_compute_image.fgt_image.self_link
    prefix          = var.prefix
    c_id            = var.c2_id 

    region-1        = var.region-1
    region-2        = var.region-2
    region-1_zone   = var.region-1_zone
    region-2_zone   = var.region-2_zone

    subnet_names    = module.vpc-c2.subnet_names
    subnet_cidrs    = module.vpc-c2.subnet_cidrs

    ipsec-psk-key   = random_string.ipsec-psk-key.result
    api-key         = random_string.api-key.result
    admin-cidr      = var.admin-cidr

    ic-peer_cidrs = {
        ic-1          = module.vpc-c1.vpc_cidrs["ic-1"]
        ic-2          = module.vpc-c1.vpc_cidrs["ic-2"]
        ic-pro        = module.vpc-c1.subnet_cidrs["private-pro"]
    }

    ic-peer_ips = {
        ic-1          = cidrhost(module.vpc-c1.subnet_cidrs["ic-1-s1"],10)
        ic-2          = cidrhost(module.vpc-c1.subnet_cidrs["ic-2-s2"],10)
        ic-hck        = cidrhost(module.vpc-c1.subnet_cidrs["private-pro"],15)
    }
    ipsec_ips = {
        local-1       = "10.0.10.2"
        peer-1        = "10.0.10.1"
        local-2       = "10.0.20.2"
        peer-2        = "10.0.20.1"
    } 
}

