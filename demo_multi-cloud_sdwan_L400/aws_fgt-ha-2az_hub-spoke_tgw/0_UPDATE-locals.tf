#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  count = 1

  prefix     = "demo-multi-cloud"
  admin_port = "8443"
  admin_cidr = "${chomp(data.http.my-public-ip.body)}/32"

  instance_type    = "c6i.large"
  fgt_build        = "build1396"
  fgt_license_type = "payg"

  region = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }

  faz_license_type = "byol"
  faz_license_file = "./licenses/licenseFAZ.lic"
  fmg_license_type = "byol"
  fmg_license_file = "./licenses/licenseFMG.lic"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB locals
  #-----------------------------------------------------------------------------------------------------
  hub = {
    id                = "HUB-AWS"
    bgp-asn_hub       = "65000"
    bgp-asn_spoke     = "65000"
    vpn_cidr          = "10.10.10.0/24"
    vpn_psk           = "secret-key-123"
    cidr              = "172.20.0.0/23"
    ike-version       = "2"
    network_id        = "1"
    dpd-retryinterval = "5"
    mode-cfg          = true
  }
  hub_peer_vxlan = {
    bgp-asn   = "65000"
    public-ip = ""
    remote-ip = "10.10.30.2"
    local-ip  = "10.10.30.1"
    vni       = "1100"
  }

  tgw_bgp-asn     = "65515"
  tgw_cidr        = ["172.20.10.0/24"]
  tgw_inside_cidr = ["169.254.100.0/29", "169.254.101.0/29"]

  vpc-spoke_cidr = ["172.20.100.0/23", module.fgt_hub_vpc.subnet_az1_cidrs["bastion"]]

  #-----------------------------------------------------------------------------------------------------
  # Spoke config to HUBs
  #-----------------------------------------------------------------------------------------------------
  hubs = [
    {
      id                = local.hub["id"]
      bgp-asn           = local.hub["bgp-asn_hub"]
      public-ip         = module.fgt_hub_vpc.fgt_active_eip_public
      hub-ip            = cidrhost(cidrsubnet(local.hub["vpn_cidr"], 1, 0), 1)
      site-ip           = "" // set to "" if VPN mode-cfg is enable
      hck-srv-ip        = cidrhost(cidrsubnet(local.hub["vpn_cidr"], 1, 0), 1)
      vpn_psk           = module.fgt_hub_config.vpn_psk
      cidr              = local.hub["cidr"]
      ike-version       = local.hub["ike-version"]
      network_id        = local.hub["network_id"]
      dpd-retryinterval = local.hub["dpd-retryinterval"]
    },
    {
      id                = local.hub["id"]
      bgp-asn           = local.hub["bgp-asn_hub"]
      public-ip         = module.fgt_hub_vpc.fgt_passive_eip_public
      hub-ip            = cidrhost(cidrsubnet(local.hub["vpn_cidr"], 1, 1), 1)
      site-ip           = "" // set to "" if VPN mode-cfg is enable
      hck-srv-ip        = cidrhost(cidrsubnet(local.hub["vpn_cidr"], 1, 1), 1)
      vpn_psk           = module.fgt_hub_config.vpn_psk
      cidr              = local.hub["cidr"]
      ike-version       = local.hub["ike-version"]
      network_id        = local.hub["network_id"]
      dpd-retryinterval = local.hub["dpd-retryinterval"]
    }
  ]
}
