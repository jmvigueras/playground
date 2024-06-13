locals {
  #-----------------------------------------------------------------------------------------------------
  # Test variables
  #-----------------------------------------------------------------------------------------------------
  number_ipsec_aggr  = 16 //number of IPSEC tunnel to aggregate
  number_iperf_test  = 8  //number of linux vm performing IPERF between sites

  #-----------------------------------------------------------------------------------------------------
  # Context locals
  #-----------------------------------------------------------------------------------------------------
  rg_name                  = null        // it will create a new one if null
  storage-account_endpoint = null        // it will create a new one if null
  prefix                   = "ipsec-aggr" // prefix added in azure assets

  tags = {
    Deploy   = "Azure test s2s ipsec"
    Project  = "Fortinet demo"
    Username = "jvigueras"
  }

  admin_port     = "8443"
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  fgt_size         = "Standard_F16s_v2"
  fgt_license_type = "payg"
  fgt_version      = "7.2.8"

  //admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"
  admin_cidr = "0.0.0.0/0"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB regions variables
  #-----------------------------------------------------------------------------------------------------
  # Azure regions
  region_1 = "francecentral"

  # Region cidrs (/16)
  r1_cidr = "10.1.0.0/16"

  # BGP ASN
  r1_hub_azure_core_bgp_asn = "65000"
  r1_hub_on_prem_bgp_asn    = "65001"
  
  # Hub to Hub IPSEC private cidrs
  r1_to_r1_cidr = "172.16.11.0/24"

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB Azure region 1
  #-----------------------------------------------------------------------------------------------------
  # Cluster types
  r1_hub_azure_core_type  = "fgcp"
  r1_hub_azure_sdwan_type = "fgcp"
  # FGT VNets cidr ranges
  r1_hub_azure_core_vnet_cidr = cidrsubnet(local.r1_cidr, 4, 0)
  # FGT Spoke VNets cidr ranges
  r1_hub_azure_spoke_vnet_cidrs = cidrsubnet(local.r1_cidr, 4, 1)
  # HUB to HUB IPSEC tunnels config
  r1_hub_azure_core_h2h = local.r1_hub_azure_core_h2h_public
  r1_hub_azure_core_h2h_public = [for i in range(0, local.number_ipsec_aggr) :
    {
      id                = "to-op"
      remote_gw         = module.r1_hub_on_prem_xlb.elb_public-ip
      bgp_asn_remote    = local.r1_hub_on_prem_bgp_asn
      vpn_port          = "public"
      vpn_psk           = random_string.vpn_psk.result
      ike_version       = "2"
      network_id        = tostring(10 + i)
      dpd_retryinterval = "5"
    }
  ]
  # xLB 
  config_gwlb              = false
  r1_hub_azure_core_ilb_ip = cidrhost(module.r1_hub_azure_core_vnet.subnet_cidrs["private"], 9)
  backend-probe_port       = "8008"
  
  # Fortigate
  fgt_ports = {
    public  = "port1"
    private = "port2"
    mgtm    = "port3"
  }

  #-----------------------------------------------------------------------------------------------------
  # FGT HUB On-premises region 1
  #-----------------------------------------------------------------------------------------------------
  # Cluster types
  r1_hub_on_prem_type = "fgcp"
  # FGT VNets cidr ranges
  r1_hub_on_prem_vnet_cidr = cidrsubnet(local.r1_cidr, 4, 5)
  # FGT spoke peered VNets peering
  r1_hub_on_prem_spoke_vnet_cidrs = cidrsubnet(local.r1_cidr, 4, 6)
  # HUB to HUB IPSEC tunnels config
  r1_hub_on_prem_h2h = local.r1_hub_on_prem_h2h_public
  r1_hub_on_prem_h2h_public = [for i in range(0, local.number_ipsec_aggr) :
    {
      id                = "to-hub"
      remote_gw         = module.r1_hub_azure_xlb.elb_public-ip
      bgp_asn_remote    = local.r1_hub_azure_core_bgp_asn
      vpn_port          = "public"
      vpn_psk           = random_string.vpn_psk.result
      ike_version       = "2"
      network_id        = tostring(10 + i)
      dpd_retryinterval = "5"
    }
  ]
  # xLB 
  r1_hub_on_prem_ilb_ip = cidrhost(module.r1_hub_on_prem_vnet.subnet_cidrs["private"], 9)

}