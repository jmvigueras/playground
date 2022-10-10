# Create new random API key to be provisioned in FortiGates.
resource "random_string" "advpn-ipsec-psk" {
  length                 = 25
  special                = false
  numeric                = true
}

// Create VPC-SEC
module "vpc-sec" {
    source = "github.com/jmvigueras/playground/SecDayMad//modules/hubAWS/modules/vpc-sec"

    prefix          = var.prefix
    admin_cidr      = var.admin_cidr
    admin_port      = var.admin_port
    region          = var.region

    vpc-sec_net     = var.vpc-sec_net
    vpc-spoke-1_net = var.vpc-spoke-1_net
    vpc-spoke-2_net = var.vpc-spoke-2_net

    tgw_id          = aws_ec2_transit_gateway.tgw.id
}

// Create VPC-SPOKES
module "vpc-spoke" {
    source = "github.com/jmvigueras/playground/SecDayMad//modules/hubAWS/modules/vpc-spoke"

    prefix          = var.prefix
    region          = var.region

    vpc-spoke-1_net = var.vpc-spoke-1_net
    vpc-spoke-2_net = var.vpc-spoke-2_net
    
    tgw_id         = aws_ec2_transit_gateway.tgw.id
}

// Create Active FGT
module "fgt-ha" {
    source = "github.com/jmvigueras/playground/SecDayMad//modules/hubAWS/modules/fgt-ha"

    prefix          = var.prefix
    admin_cidr      = var.admin_cidr
    admin_port      = var.admin_port
    region          = var.region
    keypair         = var.keypair
    bootstrap-fgt   = var.bootstrap-fgt

    vpc-sec_net         = var.vpc-sec_net
    vpc-spoke-1_net     = var.vpc-spoke-1_net
    vpc-spoke-2_net     = var.vpc-spoke-2_net

    eni-active          = module.vpc-sec.eni-active
    eni-passive         = module.vpc-sec.eni-passive

    subnet-az1-vpc-sec  = module.vpc-sec.subnet-az1-vpc-sec
    subnet-az2-vpc-sec  = module.vpc-sec.subnet-az2-vpc-sec

    subnet-vpc-spoke    = module.vpc-spoke.subnet-vpc-spoke

    hub                 = var.hub
    hub-peer            = var.hub-peer
    sites_bgp-asn       = var.sites_bgp-asn

    advpn-ipsec-psk     = random_string.advpn-ipsec-psk.result
}

