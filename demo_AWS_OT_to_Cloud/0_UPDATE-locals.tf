#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "demo-ot-box"
  region = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }
  #-----------------------------------------------------------------------------------------------------
  # FGT locals
  #-----------------------------------------------------------------------------------------------------
  admin_port = "8443"
  admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"

  instance_type = "c6i.large"
  fgt_build     = "build1396"
  license_type  = "payg"
  #-----------------------------------------------------------------------------------------------------
  # FGT HUB IT
  #-----------------------------------------------------------------------------------------------------
  hub_it_cluster_type   = "fgcp"
  hub_it_fgt_vpc_cidr   = "172.20.0.0/24"
  hub_it_spoke_vpc_cidr = "172.20.100.0/24"
  count_it_spoke_vpcs   = 1

  hub_it = [{
    id                = "HubIT"
    bgp_asn_hub       = "65000"
    bgp_asn_spoke     = "65000"
    vpn_cidr          = "10.10.10.0/24"
    vpn_psk           = "secret-key-123"
    cidr              = local.hub_it_spoke_vpc_cidr
    ike_version       = "2"
    network_id        = "1"
    dpd_retryinterval = "5"
    mode_cfg          = true
    vpn_port          = "public"
  }]

  tgw_it_bgp_asn     = "65515"
  tgw_it_cidr        = ["172.20.10.0/24"]
  tgw_it_inside_cidr = ["169.254.100.0/29", "169.254.101.0/29"]
  #-----------------------------------------------------------------------------------------------------
  # FGT HUB OT
  #-----------------------------------------------------------------------------------------------------
  hub_ot_cluster_type   = "fgcp"
  hub_ot_fgt_vpc_cidr   = "172.30.0.0/23"
  hub_ot_spoke_vpc_cidr = "172.30.100.0/23"
  count_ot_spoke_vpcs   = 1

  hub_ot = [{
    id                = "HubOT"
    bgp_asn_hub       = "65000"
    bgp_asn_spoke     = "65000"
    vpn_cidr          = "10.10.20.0/24"
    vpn_psk           = "secret-key-123"
    cidr              = local.hub_ot_spoke_vpc_cidr
    ike_version       = "2"
    network_id        = "1"
    dpd_retryinterval = "5"
    mode_cfg          = true
    vpn_port          = "public"
  }]

  tgw_ot_bgp_asn     = "65515"
  tgw_ot_cidr        = ["172.30.10.0/24"]
  tgw_ot_inside_cidr = ["169.254.100.0/29", "169.254.101.0/29"]

  #-----------------------------------------------------------------------------------------------------
  # FGT SDWAN OT-BOX
  #-----------------------------------------------------------------------------------------------------
  count_fgt_ot_boxes = 1

  spoke = {
    id      = "ot-box"
    cidr    = "192.168.0.0/24"
    bgp-asn = local.hub_it[0]["bgp_asn_spoke"]
  }

  hubs  = concat(local.hubs1, local.hubs2)
  hubs1 = concat(local.hubs1_public, local.hub_it_cluster_type == "fgsp" ? local.hubs1_public_fgsp : [])
  hubs2 = concat(local.hubs2_public, local.hub_ot_cluster_type == "fgsp" ? local.hubs2_public_fgsp : [])
  hubs1_public = [for hub in local.hub_it :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = module.fgt_hub_it.fgt_active_eip_public
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.hub_it_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      site_ip           = ""
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.hub_it_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      vpn_psk           = module.fgt_hub_it_config.vpn_psk
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  hubs1_public_fgsp = [for hub in local.hub_it :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = module.fgt_hub_it.fgt_passive_eip_public
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      site_ip           = ""
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      vpn_psk           = module.fgt_hub_it_config.vpn_psk
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  hubs2_public = [for hub in local.hub_ot :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = module.fgt_hub_ot.fgt_active_eip_public
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.hub_ot_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      site_ip           = ""
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.hub_ot_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      vpn_psk           = module.fgt_hub_ot_config.vpn_psk
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  hubs2_public_fgsp = [for hub in local.hub_ot :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = module.fgt_hub_ot.fgt_passive_eip_public
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      site_ip           = ""
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      vpn_psk           = module.fgt_hub_ot_config.vpn_psk
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
}
