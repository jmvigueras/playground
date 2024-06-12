locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  region = "europe-west2"
  zone1  = "europe-west2-a"
  zone2  = "europe-west2-b"
  prefix = "demo-bank"
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  license_type  = "payg"
  instance_type = "n1-standard-4"

  admin_port = "8443"
  #admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"
  admin_cidr = "0.0.0.0/0"

  cluster_type = "fgcp"
  fgt_passive  = true
  fgt_version  = "728"

  #-----------------------------------------------------------------------------------------------------
  # FGT Cloud
  #-----------------------------------------------------------------------------------------------------
  cloud_vpc_cidr       = "172.30.0.0/24"
  cloud_peer_vpc_cidrs = ["172.30.10.0/24"]

  cloud_ilb_ip_1 = cidrhost(module.cloud_vpc.subnet_cidrs["private"], 8)
  cloud_ilb_ip_2 = cidrhost(module.cloud_vpc.subnet_cidrs["private"], 9)

  cloud_spoke = {
    id      = "cloud-gcp"
    cidr    = local.cloud_vpc_cidr
    bgp_asn = local.onprem_hub[0]["bgp_asn_spoke"]
  }

  cloud_hubs = [
    {
      id                = "onprem"
      bgp_asn           = local.onprem_hub[0]["bgp_asn_hub"]
      external_ip       = module.onprem_vpc.fgt-active-ni_ips["private"] // primary IP
      hub_ip            = cidrhost(local.onprem_hub[0]["vpn_cidr"], 1)
      site_ip           = ""
      hck_ip            = cidrhost(local.onprem_hub[0]["vpn_cidr"], 1)
      vpn_psk           = local.onprem_hub[0]["vpn_psk"]
      cidr              = local.onprem_hub[0]["cidr"]
      ike_version       = "2"
      network_id        = "10"
      dpd_retryinterval = "5"
      sdwan_port        = "private"
      local_gw          = local.cloud_ilb_ip_1
    },
    {
      id                = "onprem"
      bgp_asn           = local.onprem_hub[1]["bgp_asn_hub"]
      external_ip       = module.onprem_vpc.fgt-passive-ni_ips["private"] // secondary IP
      hub_ip            = cidrhost(local.onprem_hub[1]["vpn_cidr"], 1)
      site_ip           = ""
      hck_ip            = cidrhost(local.onprem_hub[1]["vpn_cidr"], 1)
      vpn_psk           = local.onprem_hub[1]["vpn_psk"]
      cidr              = local.onprem_hub[1]["cidr"]
      ike_version       = "2"
      network_id        = "11"
      dpd_retryinterval = "5"
      sdwan_port        = "private"
      local_gw          = local.cloud_ilb_ip_2
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # FGT Cloud - VPN
  #-----------------------------------------------------------------------------------------------------
  cloud_vpn1_vpc_cidr = "172.30.100.0/24"
  
  cloud_vpn1_bgp_asn = "65021"
  cloud_vpn1_ips = {
    public  = cidrhost(module.cloud_vpn1_vpc.subnet_cidrs["public"], 12),
    private = cidrhost(module.cloud_vpn1_vpc.subnet_cidrs["private"], 12)
  }

  cloud_cloud_router_bgp_asn = "65022"
  cloud_cloud_router_ips = [
    cidrhost(module.cloud_vpn1_vpc.subnet_cidrs["private"], 5),
    cidrhost(module.cloud_vpn1_vpc.subnet_cidrs["private"], 6)
  ]

  cloud_s2s = [
    {
      id                = "s2s"
      remote_gw         = module.onprem_vpn1.fgt_eip_public
      bgp_asn_remote    = local.onprem_vpn1_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = "10.10.10.0/27"
      vpn_psk           = "secret-key"
      vpn_local_ip      = "10.10.10.1"
      vpn_remote_ip     = "10.10.10.2"
      ike_version       = "2"  // if skipped (default 2)
      network_id        = "11" // if skipped (default 1)
      dpd_retryinterval = "5"  // if skipped (default 5)
      hck_ip            = "10.10.10.2"
      remote_cidr       = local.onprem_vpc_cidr
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # FGT ONPREM
  #-----------------------------------------------------------------------------------------------------
  onprem_vpc_cidr = "10.30.0.0/23"

  onprem_hub = [
    {
      id                = "op-isp1"
      bgp_asn_hub       = "65010"
      bgp_asn_spoke     = "65020"
      vpn_cidr          = "10.10.0.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = local.onprem_vpc_cidr
      ike_version       = "2"
      network_id        = "10"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
      local_gw          = module.onprem_vpc.fgt-active-ni_ips["private"]
    },
    {
      id                = "op-isp2"
      bgp_asn_hub       = "65010"
      bgp_asn_spoke     = "65020"
      vpn_cidr          = "10.10.10.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = local.onprem_vpc_cidr
      ike_version       = "2"
      network_id        = "11"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
      local_gw          = module.onprem_vpc.fgt-passive-ni_ips["private"]
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # FGT on-prem - VPN
  #-----------------------------------------------------------------------------------------------------
  onprem_vpn1_bgp_asn = "65011"
  onprem_vpn1_ips = {
    public  = cidrhost(module.onprem_vpc.subnet_cidrs["public"], 12),
    private = cidrhost(module.onprem_vpc.subnet_cidrs["private"], 12)
  }

  onprem_cloud_router_bgp_asn = "65012"
  onprem_cloud_router_ips = [
    cidrhost(module.onprem_vpc.subnet_cidrs["private"], 5),
    cidrhost(module.onprem_vpc.subnet_cidrs["private"], 6)
  ]

  onprem_s2s = [
    {
      id                = "s2s"
      remote_gw         = module.cloud_vpn1.fgt_eip_public
      bgp_asn_remote    = local.cloud_vpn1_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = "10.10.10.0/27"
      vpn_psk           = "secret-key"
      vpn_local_ip      = "10.10.10.2"
      vpn_remote_ip     = "10.10.10.1"
      ike_version       = "2"  // if skipped (default 2)
      network_id        = "11" // if skipped (default 1)
      dpd_retryinterval = "5"  // if skipped (default 5)
      hck_ip            = "10.10.10.1"
      remote_cidr       = local.cloud_vpc_cidr
    }
  ]
}