#-----------------------------------------------------------------------------------
# Predefined variables for BGP
#-----------------------------------------------------------------------------------
variable "bgp_asn_default" {
  description = "Default BGP ASN"
  type        = string
  default     = "65000"
}

#-----------------------------------------------------------------------------------
# Predefined variables for SPOKE
# - config_spoke = false
#-----------------------------------------------------------------------------------
variable "config_spoke" {
  description = "Boolean varible to configure fortigate as SDWAN spoke"
  type        = bool
  default     = false
}

variable "spoke" {
  description = "Default parameters to configure a site"
  type        = map(any)
  default = {
    id      = "fgt"
    cidr    = "172.30.0.0/23"
    bgp_asn = "65000"
  }
}

variable "hubs" {
  description = "Details to crate VPN connections and SDWAN config"
  type        = list(map(string))
  default = [
    {
      id                = "HUB"
      bgp_asn           = "65000"
      external_ip       = "11.11.11.11"         // leave in blank if use external_fqdn   
      external_fqdn     = "hub-vpn.example.com" // leave in blank if use external_ip
      hub_ip            = "172.20.30.1"
      site_ip           = "172.20.30.10" // set to "" if VPN mode_cfg is enable
      hck_ip            = "172.20.30.1"
      vpn_psk           = "secret"
      cidr              = "172.20.30.0/24"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      sdwan_port        = "public"
    }
  ]
}

#-----------------------------------------------------------------------------------
# Predefined variables for HUB
# - config_hub   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_hub" {
  description = "Boolean varible to configure fortigate as a SDWAN HUB"
  type        = bool
  default     = false
}

variable "hub" {
  description = "Map of string with details to create VPN HUB"
  type        = list(map(string))
  default = [
    {
      id                = "HUB"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.1.1.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.30.0.0/24"
      ike_version       = "2" // if skipped (default 2)
      network_id        = "1" // if skipped (default 1)
      dpd_retryinterval = "5" // if skipped (default 5)
      mode_cfg          = true
      vpn_port          = "public"
    }
  ]
}

#-----------------------------------------------------------------------------------
# Config VXLAN tunnels
# - config_hub   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_vxlan" {
  description = "Boolean varible to configure VXLAN connections"
  type        = bool
  default     = false
}

variable "vxlan_peers" {
  description = "Details for vxlan connections beteween fortigates"
  type        = list(map(string))
  default = [{}]
}

#-----------------------------------------------------------------------------------
# Config Site to Site tunnels
# - config_s2s   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_s2s" {
  description = "Boolean varible to configure IPSEC site to site connections"
  type        = bool
  default     = false
}

variable "s2s_peers" {
  description = "Details for site to site connections beteween fortigates"
  type        = list(map(string))
  default = [{
    id                = "s2s"
    remote_gw         = "11.11.11.22"
    bgp_asn_remote    = "65000"
    vpn_port          = "public"
    vpn_cidr          = "10.10.10.0/27"
    vpn_psk           = "secret-key"
    vpn_local_ip      = "10.10.10.1"
    vpn_remote_ip     = "10.10.10.2"
    ike_version       = "2"  // if skipped (default 2)
    network_id        = "11" // if skipped (default 1)
    dpd_retryinterval = "5"  // if skipped (default 5)
    hck_ip            = "10.10.10.2"
    remote_cidr       = "172.20.0.0/24"
    }
  ]
}

#-----------------------------------------------------------------------------------
# Predefined variables for TGW (GRE connection)
# - config_tgw-gre   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_tgw_gre" {
  description = "Boolean varible to configure TGW GRE tunnels to a AWS TGW"
  type        = bool
  default     = false
}

variable "tgw_gre_peer" {
  description = "Details to create a GRE tunnel to a AWS TGW"
  type        = map(string)
  default = {
    gre_name      = "gre-to-tgw"
    tgw_ip        = "172.20.10.10"
    inside_cidr   = "169.254.101.0/29"
    tgw_bgp_asn   = "65011"
    route_map_out = ""
    route_map_in  = ""
  }
}

#-----------------------------------------------------------------------------------
# Predefined variables for GWLB (Geneve)
# - config_tgw-gre   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_gwlb" {
  description = "Boolean varible to configure GENEVE tunnels to a AWS GWLB"
  type        = bool
  default     = false
}

variable "gwlbe_ip" {
  description = "GWLB IP to create GENEVE tunnel"
  type        = string
  default     = ""
}

variable "gwlb_inspection_cidrs" {
  description = "List of inspection CIRDS, used to create policy route maps"
  type        = list(string)
  default     = ["192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12"]
}

#-----------------------------------------------------------------------------------
# Predefined variables for FMG 
# - config_fmg = false (default) 
#-----------------------------------------------------------------------------------
variable "config_fmg" {
  description = "Boolean varible to configure FortiManger"
  type        = bool
  default     = false
}

variable "fmg_ip" {
  description = "FortiManager IP"
  type        = string
  default     = ""
}

variable "fmg_sn" {
  description = "FortiManager SN"
  type        = string
  default     = ""
}

variable "fmg_interface_select_method" {
  description = "Fortigate interface select method to connect to FortiManager"
  type        = string
  default     = ""
}

variable "fmg_fgt_source_ip" {
  description = "Fortigate source IP used to connect with Fortimanager"
  type        = string
  default     = ""
}

#-----------------------------------------------------------------------------------
# Predefined variables for FAZ 
# - config_faz = false (default) 
#-----------------------------------------------------------------------------------
variable "config_faz" {
  description = "Boolean varible to configure FortiManger"
  type        = bool
  default     = false
}

variable "faz_ip" {
  description = "FortiAnaluzer IP"
  type        = string
  default     = ""
}

variable "faz_sn" {
  description = "FortiAnalyzer SN"
  type        = string
  default     = ""
}

variable "faz_interface_select_method" {
  description = "Fortigate interface select method to connect to FortiManager"
  type        = string
  default     = ""
}

variable "faz_fgt_source_ip" {
  description = "Fortigate source IP used to connect with FortiAnalyzer"
  type        = string
  default     = ""
}

#-----------------------------------------------------------------------------------
# HA variables
# - config_fgsp = false (default)
# - config_fgcp = false (default)
# - auto_scale  = false (default)
#-----------------------------------------------------------------------------------
variable "config_fgcp" {
  description = "Boolean varible to configure FortiGate Cluster type FGCP"
  type        = bool
  default     = false
}

variable "config_fgsp" {
  description = "Boolean varible to configure FortiGate Cluster type FGSP"
  type        = bool
  default     = false
}

variable "config_auto_scale" {
  description = "Boolean variable to configure auto-scale sync config between fortigates"
  type        = bool
  default     = false
}

variable "fgt_id" {
  description = "Fortigate name"
  type        = string
  default     = "az1.fgt1"
}

variable "ha_master_id" {
  description = "Name of fortigate instance acting as master of the cluster"
  type        = string
  default     = "az1.fgt1"
}

variable "fgt_id_prefix" {
  description = "Fortigate name prefix"
  type        = string
  default     = "fgt"
}

variable "fgsp_port" {
  description = "Type of port used to sync with other members of cluster in FGSP type"
  type        = string
  default     = "private"
}

variable "fgcp_port" {
  description = "Type of port used to sync with other members of cluster in FGCP type"
  type        = string
  default     = "mgmt"
}

variable "ha_members" {
  description = "Map of string with details of cluster members"
  type        = map(list(map(string)))
  default     = {}
}

variable "auto_scale_secret" {
  description = "Fortigate auto scale password"
  type        = string
  default     = "nh62znfkzajz2o9"
}

variable "auto_scale_sync_port" {
  description = "Type of port used to sync config betweewn fortigates"
  type        = string
  default     = "private"
}

#-----------------------------------------------------------------------------------
# General variables
#-----------------------------------------------------------------------------------
variable "config_fw_policy" {
  description = "Boolean variable to configure basic allow all policies"
  type        = bool
  default     = true
}

variable "admin_cidr" {
  description = "CIDR range where fortigate can be administrate"
  type        = string
  default     = "0.0.0.0/0"
}

variable "admin_port" {
  description = "Fortigate administration port"
  type        = string
  default     = "8443"
}

variable "api_key" {
  description = "Fortigate API Key to remote admin"
  type        = string
  default     = null
}

variable "config_extra" {
  description = "Add extra config to bootstrap config generated"
  type        = string
  default     = ""
}

variable "static_route_cidrs" {
  description = "List of CIDRs to add as static routes"
  type        = list(string)
  default     = null
}

variable "ports" {
  description = "Map of type of port and their assignations"
  type        = map(string)
  default = {
    public  = "port1"
    private = "port2"
    mgtm    = "port3"
    ha      = "port3"
  }
}

variable "default_private_port" {
  description = "Name of default private port"
  type        = string
  default     = "private"
}

variable "ports_config" {
  description = "List of maps of ports details"
  type        = list(map(string))
  default     = []
}

variable "license_type" {
  description = "License Type to create FortiGate-VM"
  type        = string
  default     = "payg"
}

variable "license_file" {
  description = "License file path for the active fgt"
  type        = string
  default     = "./licenses/license1.lic"
}

variable "fortiflex_token" {
  description = "FortiFlex token"
  type        = string
  default     = ""
}

variable "rsa_public_key" {
  description = "SSH RSA public key for KeyPair"
  type        = string
  default     = null
}

variable "backend_probe_port" {
  description = "Backend probe port if configuring NLB or ALB"
  type        = string
  default     = "8008"
}