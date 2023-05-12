#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  count = 2

  prefix     = "demo-multi-cloud"
  admin_port = "8443"
  admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"

  instance_type    = "c6i.large"
  fgt_build        = "build1396"
  fgt_license_type = "payg"

  region = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }

  #-----------------------------------------------------------------------------------------------------
  # FAZ and FMG locals
  #-----------------------------------------------------------------------------------------------------
  faz_license_type = "byol"
  faz_license_file = "./licenses/licenseFAZ.lic"
  fmg_license_type = "byol"
  fmg_license_file = "./licenses/licenseFMG.lic"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB locals
  #-----------------------------------------------------------------------------------------------------
  fgt_hub_vpc_cidr = "172.20.0.0/24"
  hub = [
    {
      id                = "HUB-AWS"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.10.10.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = local.fgt_hub_vpc_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
    }
  ]
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
      id                = local.hub[0]["id"]
      bgp_asn           = local.hub[0]["bgp_asn_hub"]
      external_ip       = module.fgt_hub.fgt_active_eip_public
      hub_ip            = cidrhost(cidrsubnet(local.hub[0]["vpn_cidr"], 1, 0), 1)
      site_ip           = "" // set to "" if VPN mode-cfg is enable
      hck_ip            = cidrhost(cidrsubnet(local.hub[0]["vpn_cidr"], 1, 0), 1)
      vpn_psk           = module.fgt_hub_config.vpn_psk
      cidr              = local.hub[0]["cidr"]
      ike_version       = local.hub[0]["ike_version"]
      network_id        = local.hub[0]["network_id"]
      dpd_retryinterval = local.hub[0]["dpd_retryinterval"]
      sdwan_port        = "public"
    },
    {
      id                = local.hub[0]["id"]
      bgp_asn           = local.hub[0]["bgp_asn_hub"]
      external_ip       = module.fgt_hub.fgt_passive_eip_public
      hub_ip            = cidrhost(cidrsubnet(local.hub[0]["vpn_cidr"], 1, 1), 1)
      site_ip           = "" // set to "" if VPN mode-cfg is enable
      hck_ip            = cidrhost(cidrsubnet(local.hub[0]["vpn_cidr"], 1, 1), 1)
      vpn_psk           = module.fgt_hub_config.vpn_psk
      cidr              = local.hub[0]["cidr"]
      ike_version       = local.hub[0]["ike_version"]
      network_id        = local.hub[0]["network_id"]
      dpd_retryinterval = local.hub[0]["dpd_retryinterval"]
      sdwan_port        = "public"
    }
  ]
}