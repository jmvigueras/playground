locals {
  #-----------------------------------------------------------------------------------------------------
  # Context locals
  #-----------------------------------------------------------------------------------------------------
  resource_group_name      = null             // it will create a new one if null
  storage-account_endpoint = null             // it will create a new one if null
  location                 = "francecentral"  // default location
  prefix                   = "demo-hub-spoke" // prefix added in azure assets

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

  fmg-faz_license_type = "byol"
  faz_license_file     = "./licenses/licenseFAZ.lic"
  fmg_license_file     = "./licenses/licenseFMG.lic"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB locals
  #-----------------------------------------------------------------------------------------------------
  hub1 = [
    {
      id                = "HUB1"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.10.10.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.30.0.0/24"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
    }
  ]

  admin_cidr = "0.0.0.0/0"

  #-----------------------------------------------------------------------------------------------------
  # FGT Spoke locals
  #-----------------------------------------------------------------------------------------------------
  spoke = {
    id      = "spoke-1"
    cidr    = "172.30.10.0/24"
    bgp_asn = "65000"
  }
  hubs = [
    {
      id                = local.hub1[0]["id"]
      bgp_asn           = local.hub1[0]["bgp_asn_hub"]
      external_ip       = module.fgt_hub_vnet.fgt-active-public-ip
      hub_ip            = cidrhost(cidrsubnet(local.hub1[0]["vpn_cidr"], 1, 0), 1)
      site_ip           = "" // set to "" if VPN mode-cfg is enable
      hck_ip            = cidrhost(cidrsubnet(local.hub1[0]["vpn_cidr"], 1, 0), 1)
      vpn_psk           = local.hub1[0]["vpn_psk"]
      cidr              = local.hub1[0]["cidr"]
      ike_version       = local.hub1[0]["ike_version"]
      network_id        = local.hub1[0]["network_id"]
      dpd_retryinterval = local.hub1[0]["dpd_retryinterval"]
      sdwan_port        = "public"
    },
    {
      id                = local.hub1[0]["id"]
      bgp_asn           = local.hub1[0]["bgp_asn_hub"]
      external_ip       = module.fgt_hub_vnet.fgt-passive-public-ip
      hub_ip            = cidrhost(cidrsubnet(local.hub1[0]["vpn_cidr"], 1, 1), 1)
      site_ip           = "" // set to "" if VPN mode-cfg is enable
      hck_ip            = cidrhost(cidrsubnet(local.hub1[0]["vpn_cidr"], 1, 1), 1)
      vpn_psk           = local.hub1[0]["vpn_psk"]
      cidr              = local.hub1[0]["cidr"]
      ike_version       = local.hub1[0]["ike_version"]
      network_id        = local.hub1[0]["network_id"]
      dpd_retryinterval = local.hub1[0]["dpd_retryinterval"]
      sdwan_port        = "public"
    }
  ]
}

