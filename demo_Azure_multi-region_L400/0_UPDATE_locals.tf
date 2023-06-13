locals {
  #-----------------------------------------------------------------------------------------------------
  # Context locals
  #-----------------------------------------------------------------------------------------------------
  r1_resource_group_name   = null                // it will create a new one if null
  r2_resource_group_name   = null                // it will create a new one if null
  r3_resource_group_name   = null                // it will create a new one if null
  storage-account_endpoint = null                // it will create a new one if null
  prefix                   = "demo-multi-region" // prefix added in azure assets

  tags = {
    Deploy  = "Forti demo hub spoke"
    Project = "Forti SDWAN"
  }

  admin_port     = "8443"
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  fgt_size         = "Standard_F4s"
  fmg-faz_size     = "Standard_F4s"
  fgt_license_type = "payg"
  fgt_version      = "7.2.4"

  fmg-faz_license_type = "byol"
  faz_license_file     = "./licenses/licenseFAZ.lic"
  fmg_license_file     = "./licenses/licenseFMG.lic"

  admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"
  //admin_cidr = "0.0.0.0/0"

  fgt_ports = {
    public  = "port1"
    private = "port2"
    mgtm    = "port3"
  }

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB regions variables
  #-----------------------------------------------------------------------------------------------------
  # Azure regions
  region_1 = "francecentral"
  region_2 = "westeurope"
  region_3 = "westeurope"
  # Zones ID
  r1_hub_on_prem_id     = "EMEA"
  r1_hub_azure_sdwan_id = "EMEA"
  r1_hub_azure_core_id  = "EMEA"
  r2_hub_azure_core_id  = "LATAM"
  r3_hub_azure_core_id  = "NORAM"
  # Region cidrs (/16)
  r1_cidr = "10.1.0.0/16"
  r2_cidr = "10.2.0.0/16"
  r3_cidr = "10.3.0.0/16"
  # BGP ASN
  r1_hub_on_prem_bgp_asn     = "65010"
  r1_hub_azure_sdwan_bgp_asn = "65010"
  r1_spoke_bgp_asn           = "65010"
  r1_hub_azure_core_bgp_asn  = "65001"
  r2_hub_azure_core_bgp_asn  = "65002"
  r2_spoke_bgp_asn           = "65002"
  r3_hub_azure_core_bgp_asn  = "65003"
  r3_spoke_bgp_asn           = "65003"
  # FQDN Azure region 1 SDWAN
  //r1_hub_azure_sdwan_fqdn = "r1-sdwan.securityday-demo.com"
  r1_hub_azure_sdwan_fqdn_public  = module.r1_hub_azure_sdwan_vnet.fgt-active-public-ip
  r1_hub_azure_sdwan_fqdn_private = module.r1_hub_azure_sdwan_vnet.fgt-active-ni_ips["private"]
  # Hub to Hub IPSEC private cidrs
  r1_to_r1_cidr = "172.16.11.0/24"
  r1_to_r2_cidr = "172.16.12.0/24"
  r1_to_r3_cidr = "172.16.13.0/24"
  r2_to_r3_cidr = "172.16.23.0/24"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB Azure region 1
  #-----------------------------------------------------------------------------------------------------
  # Cluster types
  r1_hub_azure_core_type  = "fgcp"
  r1_hub_azure_sdwan_type = "fgcp"
  # SDWAN FGT number
  r1_hub_azure_sdwan_number = "2"
  # FGT VNets cidr ranges
  r1_hub_azure_core_vnet_cidr  = cidrsubnet(local.r1_cidr, 8, 0)
  r1_hub_azure_sdwan_vnet_cidr = cidrsubnet(local.r1_cidr, 8, 10)
  # FGT spoke peered VNets peering
  r1_hub_azure_spoke_vnet_cidrs = [cidrsubnet(local.r1_cidr, 8, 20)]
  # FGT SDWAN VPN config
  r1_hub_azure_sdwan = [
    {
      id                = local.r1_hub_azure_sdwan_id
      bgp_asn_hub       = local.r1_hub_azure_sdwan_bgp_asn
      bgp_asn_spoke     = local.r1_spoke_bgp_asn
      vpn_cidr          = cidrsubnet(local.r1_cidr, 8, 30)
      vpn_psk           = "secret-key-123"
      cidr              = local.r1_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
      local_gw          = module.r1_hub_azure_xlb.elb_public-ip
    },
    {
      id                = local.r1_hub_azure_sdwan_id
      bgp_asn_hub       = local.r1_hub_azure_sdwan_bgp_asn
      bgp_asn_spoke     = local.r1_spoke_bgp_asn
      vpn_cidr          = cidrsubnet(local.r1_cidr, 8, 31)
      vpn_psk           = "secret-key-123"
      cidr              = local.r1_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
      local_gw          = module.r1_hub_azure_xlb.ilb_private-ip
    }
  ]
  # HUB to HUB IPSEC tunnels config
  r1_hub_azure_core_h2h = [
    {
      id                = "to-r2"
      remote_gw         = module.r2_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r2_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r2_cidr, 2, 0)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 0), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 0), 2)
      ike_version       = "2"
      network_id        = "12"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 0), 2)
      remote_cidr       = local.r2_cidr
    },
    {
      id                = "to-r2"
      remote_gw         = local.r2_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r2_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r2_cidr, 2, 1)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 1), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 1), 2)
      ike_version       = "2"
      network_id        = "12"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 1), 2)
      remote_cidr       = local.r2_cidr
    },
    {
      id                = "to-op"
      remote_gw         = module.r1_hub_on_prem_xlb.elb_public-ip
      bgp_asn_remote    = local.r1_hub_on_prem_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r1_cidr, 2, 0)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 0), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 0), 2)
      ike_version       = "2"
      network_id        = "11"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 0), 2)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-op"
      remote_gw         = local.r1_hub_on_prem_ilb_ip
      bgp_asn_remote    = local.r1_hub_on_prem_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r1_cidr, 2, 1)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 1), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 1), 2)
      ike_version       = "2"
      network_id        = "11"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 1), 2)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r3"
      remote_gw         = module.r3_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r3_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r3_cidr, 2, 0)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 0), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 0), 2)
      ike_version       = "2"
      network_id        = "13"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 0), 2)
      remote_cidr       = local.r3_cidr
    },
    {
      id                = "to-r3"
      remote_gw         = local.r3_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r3_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r3_cidr, 2, 1)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 1), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 1), 2)
      ike_version       = "2"
      network_id        = "13"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 1), 2)
      remote_cidr       = local.r3_cidr
    }
  ]
  # xLB 
  config_gwlb              = false
  r1_hub_azure_core_ilb_ip = cidrhost(module.r1_hub_azure_core_vnet.subnet_cidrs["private"], 9)
  backend-probe_port       = "8008"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB On-premises region 1
  #-----------------------------------------------------------------------------------------------------
  # Cluster types
  r1_hub_on_prem_type = "fgcp"
  # FGT VNets cidr ranges
  r1_hub_on_prem_vnet_cidr = cidrsubnet(local.r1_cidr, 8, 4)
  # FGT SDWAN VPN config
  r1_hub_on_prem_sdwan = [
    {
      id                = local.r1_hub_on_prem_id
      bgp_asn_hub       = local.r1_hub_on_prem_bgp_asn
      bgp_asn_spoke     = local.r1_spoke_bgp_asn
      vpn_cidr          = cidrsubnet(local.r1_cidr, 8, 32)
      vpn_psk           = "secret-key-123"
      cidr              = local.r1_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
      local_gw          = module.r1_hub_on_prem_xlb.elb_public-ip
    },
    {
      id                = local.r1_hub_on_prem_id
      bgp_asn_hub       = local.r1_hub_azure_sdwan_bgp_asn
      bgp_asn_spoke     = local.r1_spoke_bgp_asn
      vpn_cidr          = cidrsubnet(local.r1_cidr, 8, 33)
      vpn_psk           = "secret-key-123"
      cidr              = local.r1_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
      local_gw          = module.r1_hub_on_prem_xlb.ilb_private-ip
    }
  ]
  # HUB to HUB IPSEC tunnels config
  r1_hub_on_prem_h2h = [
    {
      id                = "to-r2"
      remote_gw         = module.r2_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r2_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r2_cidr, 2, 2)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 2), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 2), 2)
      ike_version       = "2"
      network_id        = "12"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 2), 2)
      remote_cidr       = local.r2_cidr
    },
    {
      id                = "to-r2"
      remote_gw         = local.r2_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r2_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r2_cidr, 2, 3)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 3), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 3), 2)
      ike_version       = "2"
      network_id        = "12"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 3), 2)
      remote_cidr       = local.r2_cidr
    },
    {
      id                = "to-az"
      remote_gw         = module.r1_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r1_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r1_cidr, 2, 0)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 0), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 0), 1)
      ike_version       = "2"
      network_id        = "11"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 0), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-az"
      remote_gw         = local.r1_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r1_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r1_cidr, 2, 1)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 1), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 1), 1)
      ike_version       = "2"
      network_id        = "11"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r1_cidr, 2, 1), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r3"
      remote_gw         = module.r3_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r3_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r3_cidr, 2, 2)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 2), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 2), 2)
      ike_version       = "2"
      network_id        = "13"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 2), 2)
      remote_cidr       = local.r3_cidr
    },
    {
      id                = "to-r3"
      remote_gw         = local.r3_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r3_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r3_cidr, 2, 3)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 3), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 3), 2)
      ike_version       = "2"
      network_id        = "13"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 3), 2)
      remote_cidr       = local.r3_cidr
    }
  ]
  # xLB 
  r1_hub_on_prem_ilb_ip = cidrhost(module.r1_hub_on_prem_vnet.subnet_cidrs["private"], 9)

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB region 2 (LATAM)
  #-----------------------------------------------------------------------------------------------------
  # Cluster types
  r2_hub_azure_core_type = "fgcp"
  # SDWAN cluster number
  r2_hub_azure_sdwan_number = "1"
  # FGT VNets cidr ranges
  r2_hub_azure_core_vnet_cidr  = cidrsubnet(local.r2_cidr, 8, 0)
  r2_hub_azure_sdwan_vnet_cidr = cidrsubnet(local.r2_cidr, 8, 10)
  # FGT spoke peered VNets peering
  r2_hub_azure_spoke_vnet_cidrs = [cidrsubnet(local.r2_cidr, 8, 20)]
  # FGT SDWAN VPN config
  r2_hub_azure_sdwan = [
    {
      id                = local.r2_hub_azure_core_id
      bgp_asn_hub       = local.r2_hub_azure_core_bgp_asn
      bgp_asn_spoke     = local.r2_spoke_bgp_asn
      vpn_cidr          = cidrsubnet(local.r2_cidr, 8, 30)
      vpn_psk           = "secret-key-123"
      cidr              = local.r2_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
      local_gw          = module.r2_hub_azure_xlb.elb_public-ip
    },
    {
      id                = local.r2_hub_azure_core_id
      bgp_asn_hub       = local.r2_hub_azure_core_bgp_asn
      bgp_asn_spoke     = local.r2_spoke_bgp_asn
      vpn_cidr          = cidrsubnet(local.r2_cidr, 8, 31)
      vpn_psk           = "secret-key-123"
      cidr              = local.r2_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
      local_gw          = module.r2_hub_azure_xlb.ilb_private-ip
    }
  ]
  # HUB to HUB IPSEC tunnels config
  r2_hub_azure_core_h2h = [
    {
      id                = "to-r1"
      remote_gw         = module.r1_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r1_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r2_cidr, 2, 0)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 0), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 0), 1)
      ike_version       = "2"
      network_id        = "12"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 0), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r1"
      remote_gw         = local.r1_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r1_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r2_cidr, 2, 1)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 1), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 1), 1)
      ike_version       = "2"
      network_id        = "12"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 1), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r1"
      remote_gw         = module.r1_hub_on_prem_xlb.elb_public-ip
      bgp_asn_remote    = local.r1_hub_on_prem_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r2_cidr, 2, 2)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 2), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 2), 1)
      ike_version       = "2"
      network_id        = "12"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 2), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r1"
      remote_gw         = local.r1_hub_on_prem_ilb_ip
      bgp_asn_remote    = local.r1_hub_on_prem_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r2_cidr, 2, 3)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 3), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 3), 1)
      ike_version       = "2"
      network_id        = "12"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r2_cidr, 2, 3), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r3"
      remote_gw         = module.r3_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r3_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r2_to_r3_cidr, 2, 0)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 0), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 0), 2)
      ike_version       = "2"
      network_id        = "23"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 0), 2)
      remote_cidr       = local.r3_cidr
    },
    {
      id                = "to-r3"
      remote_gw         = local.r3_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r3_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r2_to_r3_cidr, 2, 1)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 1), 1)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 1), 2)
      ike_version       = "2"
      network_id        = "23"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 1), 2)
      remote_cidr       = local.r3_cidr
    }
  ]
  # xLB 
  r2_hub_azure_core_ilb_ip = cidrhost(module.r2_hub_azure_core_vnet.subnet_cidrs["private"], 9)

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB region 3 (NORAM)
  #-----------------------------------------------------------------------------------------------------
  # Cluster types
  r3_hub_azure_core_type = "fgcp"
  # SDWAN cluster number
  r3_hub_azure_sdwan_number = "1"
  # FGT VNets cidr ranges
  r3_hub_azure_core_vnet_cidr  = cidrsubnet(local.r3_cidr, 8, 0)
  r3_hub_azure_sdwan_vnet_cidr = cidrsubnet(local.r3_cidr, 8, 10)
  # FGT spoke peered VNets peering
  r3_hub_azure_spoke_vnet_cidrs = [cidrsubnet(local.r3_cidr, 8, 20)]
  # FGT SDWAN VPN config
  r3_hub_azure_sdwan = [
    {
      id                = local.r3_hub_azure_core_id
      bgp_asn_hub       = local.r3_hub_azure_core_bgp_asn
      bgp_asn_spoke     = local.r3_spoke_bgp_asn
      vpn_cidr          = cidrsubnet(local.r3_cidr, 8, 30)
      vpn_psk           = "secret-key-123"
      cidr              = local.r3_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
      local_gw          = module.r3_hub_azure_xlb.elb_public-ip
    },
    {
      id                = local.r3_hub_azure_core_id
      bgp_asn_hub       = local.r3_hub_azure_core_bgp_asn
      bgp_asn_spoke     = local.r3_spoke_bgp_asn
      vpn_cidr          = cidrsubnet(local.r3_cidr, 8, 31)
      vpn_psk           = "secret-key-123"
      cidr              = local.r3_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
      local_gw          = module.r3_hub_azure_xlb.ilb_private-ip
    }
  ]
  # HUB to HUB IPSEC tunnels config
  r3_hub_azure_core_h2h = [
    {
      id                = "to-r1"
      remote_gw         = module.r1_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r1_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r3_cidr, 2, 0)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 0), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 0), 1)
      ike_version       = "2"
      network_id        = "13"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 0), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r1"
      remote_gw         = local.r1_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r1_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r3_cidr, 2, 1)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 1), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 1), 1)
      ike_version       = "2"
      network_id        = "13"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 1), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r1"
      remote_gw         = module.r1_hub_on_prem_xlb.elb_public-ip
      bgp_asn_remote    = local.r1_hub_on_prem_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r1_to_r3_cidr, 2, 2)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 2), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 2), 1)
      ike_version       = "2"
      network_id        = "13"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 2), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r1"
      remote_gw         = local.r1_hub_on_prem_ilb_ip
      bgp_asn_remote    = local.r1_hub_on_prem_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r1_to_r3_cidr, 2, 3)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 3), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 3), 1)
      ike_version       = "2"
      network_id        = "13"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r1_to_r3_cidr, 2, 3), 1)
      remote_cidr       = local.r1_cidr
    },
    {
      id                = "to-r2"
      remote_gw         = module.r2_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r2_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_cidr          = cidrsubnet(local.r2_to_r3_cidr, 2, 0)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 0), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 0), 1)
      ike_version       = "2"
      network_id        = "23"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 0), 1)
      remote_cidr       = local.r2_cidr
    },
    {
      id                = "to-r2"
      remote_gw         = local.r2_hub_azure_core_ilb_ip
      bgp_asn_remote    = local.r2_hub_azure_core_bgp_asn
      vpn_port          = "private"
      vpn_cidr          = cidrsubnet(local.r2_to_r3_cidr, 2, 1)
      vpn_psk           = "secret-key-123"
      vpn_local_ip      = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 1), 2)
      vpn_remote_ip     = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 1), 1)
      ike_version       = "2"
      network_id        = "23"
      dpd_retryinterval = "5"
      hck_ip            = cidrhost(cidrsubnet(local.r2_to_r3_cidr, 2, 1), 1)
      remote_cidr       = local.r2_cidr
    }
  ]
  # xLB 
  r3_hub_azure_core_ilb_ip = cidrhost(module.r3_hub_azure_core_vnet.subnet_cidrs["private"], 9)

  #-----------------------------------------------------------------------------------------------------
  # FGT Spoke - region 1
  #-----------------------------------------------------------------------------------------------------
  r1_spoke_number       = 1
  r1_spoke_cluster_type = "fgcp"
  # FMG and FAZ IP
  //fmg_ip = "108.142.155.209"
  //faz_ip = "108.142.155.210"
  # spoke config
  r1_spoke = {
    id      = "spoke"
    cidr    = cidrsubnet(local.r1_cidr, 7, 40)
    bgp_asn = local.r1_spoke_bgp_asn
  }
  # SDWAN HUB config
  hubs = concat(local.r1_hubs_azure, local.r1_hubs_on_prem)
  r1_hubs_azure = [for hub in local.r1_hub_azure_sdwan :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? local.r1_hub_azure_sdwan_fqdn_public : local.r1_hub_azure_sdwan_fqdn_private
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_azure_sdwan_type == "fgsp" ? 1 : 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_azure_sdwan_type == "fgsp" ? 1 : 0, 0), 2)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_azure_sdwan_type == "fgsp" ? 1 : 0, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  r1_hubs_on_prem = [for hub in local.r1_hub_on_prem_sdwan :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? module.r1_hub_on_prem_xlb.elb_public-ip : module.r1_hub_on_prem_xlb.ilb_private-ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_azure_sdwan_type == "fgsp" ? 1 : 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_azure_sdwan_type == "fgsp" ? 1 : 0, 0), 2)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], local.r1_hub_azure_sdwan_type == "fgsp" ? 1 : 0, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
}