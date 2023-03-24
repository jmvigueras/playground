locals {
  #-----------------------------------------------------------------------------------------------------
  # Context locals
  #-----------------------------------------------------------------------------------------------------
  r1_resource_group_name   = null                // it will create a new one if null
  r2_resource_group_name   = null                // it will create a new one if null
  storage-account_endpoint = null                // it will create a new one if null
  region_1                 = "francecentral"     // region 1
  region_2                 = "westeurope"        // region 2
  prefix                   = "demo-multi-region" // prefix added in azure assets

  tags = {
    Deploy  = "Forti demo hub spoke"
    Project = "Forti SDWAN"
  }

  admin_port     = "8443"
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  fgt_size         = "Standard_F4"
  fmg-faz_size     = "Standard_F4"
  fgt_license_type = "payg"

  admin_cidr = "0.0.0.0/0"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB locals
  #-----------------------------------------------------------------------------------------------------
  r1_hub_cluster_type = "fgcp"
  r2_hub_cluster_type = "fgcp"

  r1_hub_vnet_cidr = "172.20.0.0/24"
  r2_hub_vnet_cidr = "172.30.0.0/24"

  r1_hub_vnet_spoke_cidrs = ["172.20.100.0/23"]
  r2_hub_vnet_spoke_cidrs = ["172.30.100.0/23"]

  r1_hub = [
    {
      id                = "HUB1"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.0.1.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.20.100.0/23"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
    },
    {
      id                = "HUB1"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.0.10.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.30.100.0/23"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
    }
  ]
  r2_hub = [
    {
      id                = "HUB2"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.0.2.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.20.100.0/23"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
    },
    {
      id                = "HUB2"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.0.20.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.30.100.0/23"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
    }
  ]
  r1_hub_peer_vxlan = [
    {
      bgp_asn     = local.r2_hub[0]["bgp_asn_hub"]
      external_ip = module.r2_xlb.elb_public-ip
      remote_ip   = "10.0.3.2"
      local_ip    = "10.0.3.1"
      vni         = "1100"
      vxlan_port  = "public"
    },
    {
      bgp_asn     = local.r2_hub[0]["bgp_asn_hub"]
      external_ip = local.r2_ilb_ip
      remote_ip   = "10.0.30.2"
      local_ip    = "10.0.30.1"
      vni         = "1100"
      vxlan_port  = "private"
    }
  ]
  r2_hub_peer_vxlan = [
    {
      bgp_asn     = local.r1_hub[0]["bgp_asn_hub"]
      external_ip = module.r1_xlb.elb_public-ip
      remote_ip   = "10.0.3.1"
      local_ip    = "10.0.3.2"
      vni         = "1100"
      vxlan_port  = "public"
    },
    {
      bgp_asn     = local.r1_hub[0]["bgp_asn_hub"]
      external_ip = local.r1_ilb_ip
      remote_ip   = "10.0.30.1"
      local_ip    = "10.0.30.2"
      vni         = "1100"
      vxlan_port  = "private"
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # LB locals
  #-----------------------------------------------------------------------------------------------------
  config_gwlb        = false
  r1_ilb_ip          = cidrhost(module.r1_fgt_hub_vnet.subnet_cidrs["private"], 9)
  r2_ilb_ip          = cidrhost(module.r2_fgt_hub_vnet.subnet_cidrs["private"], 9)
  backend-probe_port = "8008"

  #-----------------------------------------------------------------------------------------------------
  # vWAN
  #-----------------------------------------------------------------------------------------------------
  r1_vhub_cidr = "172.20.10.0/23"
  r2_vhub_cidr = "172.30.10.0/23"

  #-----------------------------------------------------------------------------------------------------
  # FGT Spoke locals (region 1)
  #-----------------------------------------------------------------------------------------------------
  spoke_number       = 1
  spoke_cluster_type = "fgcp"

  spoke = {
    id      = "spoke"
    cidr    = "192.168.0.0/23"
    bgp_asn = local.r1_hub[0]["bgp_asn_spoke"]
  }

  r1_sdwan-spoke_cidrs = "192.168.100.0/23"

  hubs = concat(local.r1_hubs, local.r1_hub_cluster_type == "fgsp" ? local.r1_hubs_fgsp : [], local.r2_hubs, local.r2_hub_cluster_type == "fgsp" ? local.r2_hubs_fgsp : [])

  r1_hubs = [for hub in local.r1_hub :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? module.r1_xlb.elb_public-ip : local.r1_ilb_ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_cluster_type == "fgsp" ? 1 : 0, 0), 2)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  r1_hubs_fgsp = [for hub in local.r1_hub :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? module.r1_xlb.elb_public-ip : local.r1_ilb_ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 2)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  r2_hubs = [for hub in local.r2_hub :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? module.r2_xlb.elb_public-ip : local.r2_ilb_ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.r2_hub_cluster_type == "fgsp" ? 1 : 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], local.r2_hub_cluster_type == "fgsp" ? 1 : 0, 0), 2)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  r2_hubs_fgsp = [for hub in local.r2_hub :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? module.r2_xlb.elb_public-ip : local.r2_ilb_ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 2)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 1, 1), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
}

