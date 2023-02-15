#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # FGT HUB locals
  #-----------------------------------------------------------------------------------------------------
  hub1 = {
    id                = "HUB1"
    bgp-asn_hub       = "65000"
    bgp-asn_spoke     = "65000"
    vpn_cidr          = "10.10.10.0/24"
    vpn_psk           = "secret-key-123"
    cidr              = "172.30.100.0/24"
    ike-version       = "2"
    network_id        = "1"
    dpd-retryinterval = "5"
    mode-cfg          = true
  }
  hub2 = {
    id                = "HUB2"
    bgp-asn_hub       = "65000"
    bgp-asn_spoke     = "65000"
    vpn_cidr          = "10.10.20.0/24"
    vpn_psk           = "secret-key-123"
    cidr              = "172.30.200.0/24"
    ike-version       = "2"
    network_id        = "1"
    dpd-retryinterval = "5"
    mode-cfg          = true
  }
  hub1_peer_vxlan = {
    bgp-asn   = local.hub2["bgp-asn_hub"]
    public-ip = "11.11.11.11"
    remote-ip = "10.10.30.2"
    local-ip  = "10.10.30.1"
    vni       = "1100"
  }
  hub2_peer_vxlan = {
    bgp-asn   = local.hub1["bgp-asn_hub"]
    public-ip = "22.22.22.22"
    remote-ip = "10.10.30.1"
    local-ip  = "10.10.30.2"
    vni       = "1100"
  }
  hub1_tgw_bgp-asn        = "65515"
  hub1_tgw_cidr           = ["172.30.110.0/24"]
  hub1_tgw_inside_cidr    = ["169.254.100.0/29", "169.254.101.0/29"]

  admin_cidr = "${chomp(data.http.my-public-ip.body)}/32"

  #-----------------------------------------------------------------------------------------------------
  # FGT Spoke locals
  #-----------------------------------------------------------------------------------------------------
  spoke = {
    id      = "spoke-1"
    cidr    = "172.30.0.0/24"
    bgp-asn = "65000"
  }
  hubs = [
    {
      id                = local.hub1["id"]
      bgp-asn           = local.hub1["bgp-asn_hub"]
      public-ip         = "11.11.11.11"
      hub-ip            = cidrhost(cidrsubnet(local.hub1["vpn_cidr"], 1, 0), 1)
      site-ip           = "" // set to "" if VPN mode-cfg is enable
      hck-srv-ip        = cidrhost(cidrsubnet(local.hub1["vpn_cidr"], 1, 0), 1)
      vpn_psk           = local.hub1["vpn_psk"]
      cidr              = local.hub1["cidr"]
      ike-version       = local.hub1["ike-version"]
      network_id        = local.hub1["network_id"]
      dpd-retryinterval = local.hub1["dpd-retryinterval"]
    },
    {
      id                = local.hub1["id"]
      bgp-asn           = local.hub1["bgp-asn_hub"]
      public-ip         = "11.11.22.22"
      hub-ip            = cidrhost(cidrsubnet(local.hub1["vpn_cidr"], 1, 1), 1)
      site-ip           = "" // set to "" if VPN mode-cfg is enable
      hck-srv-ip        = cidrhost(cidrsubnet(local.hub1["vpn_cidr"], 1, 1), 1)
      vpn_psk           = local.hub1["vpn_psk"]
      cidr              = local.hub1["cidr"]
      ike-version       = local.hub1["ike-version"]
      network_id        = local.hub1["network_id"]
      dpd-retryinterval = local.hub1["dpd-retryinterval"]
    },
    {
      id                = local.hub2["id"]
      bgp-asn           = local.hub2["bgp-asn_hub"]
      public-ip         = "22.22.22.22"
      hub-ip            = cidrhost(cidrsubnet(local.hub2["vpn_cidr"], 0, 0), 1)
      site-ip           = "" // set to "" if VPN mode-cfg is enable
      hck-srv-ip        = cidrhost(cidrsubnet(local.hub2["vpn_cidr"], 0, 0), 1)
      vpn_psk           = local.hub2["vpn_psk"]
      cidr              = local.hub2["cidr"]
      ike-version       = local.hub2["ike-version"]
      network_id        = local.hub2["network_id"]
      dpd-retryinterval = local.hub2["dpd-retryinterval"]
    }
  ]
}


#-----------------------------------------------------------------------------------------------------
# FGT active-passive necessary variables 
#-----------------------------------------------------------------------------------------------------
locals {
  subnet_active_cidrs = {
    mgmt    = cidrsubnet(local.hub1["cidr"], 4, 0)
    public  = cidrsubnet(local.hub1["cidr"], 4, 1)
    private = cidrsubnet(local.hub1["cidr"], 4, 2)
    tgw     = cidrsubnet(local.hub1["cidr"], 4, 3)
    gwlb    = cidrsubnet(local.hub1["cidr"], 4, 4)
  }
  subnet_passive_cidrs = {
    mgmt    = cidrsubnet(local.hub1["cidr"], 4, 8)
    public  = cidrsubnet(local.hub1["cidr"], 4, 9)
    private = cidrsubnet(local.hub1["cidr"], 4, 10)
    tgw     = cidrsubnet(local.hub1["cidr"], 4, 11)
    gwlb    = cidrsubnet(local.hub1["cidr"], 4, 12)
  }
  fgt-active-ni_ips = {
    mgmt    = cidrhost(local.subnet_active_cidrs["mgmt"], 10)
    public  = cidrhost(local.subnet_active_cidrs["public"], 10)
    private = cidrhost(local.subnet_active_cidrs["private"], 10)
  }
  fgt-passive-ni_ips = {
    mgmt    = cidrhost(local.subnet_passive_cidrs["mgmt"], 10)
    public  = cidrhost(local.subnet_passive_cidrs["public"], 10)
    private = cidrhost(local.subnet_passive_cidrs["private"], 10)
  }
}