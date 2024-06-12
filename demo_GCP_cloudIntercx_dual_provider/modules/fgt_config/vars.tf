variable "bgp_asn_default" {
  description = "Default BGP ASN"
  type        = string
  default     = "65000"
}

variable "config_fgsp" {
  description = "Boolean varible to configure FortiGate Cluster type FGSP"
  type        = bool
  default     = false
}

#-----------------------------------------------------------------------------------
# Predefined variables for spoke config
# - config_spoke   = true (default) 
#-----------------------------------------------------------------------------------
variable "config_spoke" {
  type    = bool
  default = false
}

// Default parameters to configure a site
variable "spoke" {
  type = map(any)
  default = {
    id      = "fgt"
    cidr    = "172.30.0.0/23"
    bgp_asn = "65000"
  }
}

// Details to crate VPN connections
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
# - config_vxlan = false (default)
#-----------------------------------------------------------------------------------
variable "config_hub" {
  type    = bool
  default = false
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

variable "config_vxlan" {
  type    = bool
  default = false
}

// Details for vxlan connection to hub (simulated L2/MPLS)
variable "hub-peer_vxlan" {
  type = map(string)
  default = {
    bgp-asn   = "65000"
    public-ip = "" // leave in blank if you don't know public IP jet
    remote-ip = "10.10.30.1"
    local-ip  = "10.10.30.2"
    vni       = "1100"
  }
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
# Predefined variables for FMG 
# - config_fmg = false (default) 
#-----------------------------------------------------------------------------------
variable "config_fmg" {
  type    = bool
  default = false
}

variable "fmg_ip" {
  type    = string
  default = ""
}

variable "fmg_sn" {
  type    = string
  default = ""
}

variable "fmg_interface-select-method" {
  type    = string
  default = ""
}

variable "fmg_fgt-1_source-ip" {
  type    = string
  default = ""
}

variable "fmg_fgt-2_source-ip" {
  type    = string
  default = ""
}

#-----------------------------------------------------------------------------------
# Predefined variables for Network Connectivity Center (NCC)
# - config_ncc = false (default) 
#-----------------------------------------------------------------------------------
variable "config_ncc" {
  type    = bool
  default = false
}

variable "ncc_bgp-asn" {
  type    = string
  default = "65515"
}

variable "ncc_peers" {
  type = list(list(string))
  default = [
    ["172.30.0.68", "172.30.0.69"]
  ]
}

#-----------------------------------------------------------------------------------
# Predefined variables for xLB 
# - config_xlb = false (default) 
#-----------------------------------------------------------------------------------
variable "config_xlb" {
  type    = bool
  default = false
}

variable "ilb_ip" {
  type    = string
  default = "172.30.0.137"
}

#-----------------------------------------------------------------------------------
# Route to change by SDN connector when FGCP and no LB
#-----------------------------------------------------------------------------------
variable "route_tables" {
  type    = list(string)
  default = null
}
variable "cluster_pips" {
  type    = list(string)
  default = null
}


#-----------------------------------------------------------------------------------
# Predefined variables for FAZ 
# - config_faz = false (default) 
#-----------------------------------------------------------------------------------
variable "config_faz" {
  type    = bool
  default = false
}

variable "faz_ip" {
  type    = string
  default = ""
}

variable "faz_sn" {
  type    = string
  default = ""
}

variable "faz_interface-select-method" {
  type    = string
  default = ""
}

variable "faz_fgt-1_source-ip" {
  type    = string
  default = ""
}

variable "faz_fgt-2_source-ip" {
  type    = string
  default = ""
}


#-----------------------------------------------------------------------------------
variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "admin_port" {
  type    = string
  default = "8443"
}

variable "api_key" {
  type    = string
  default = null
}

variable "fgt_extra-config" {
  type    = string
  default = ""
}

variable "vpc-spoke_cidr" {
  type    = list(string)
  default = null
}

variable "fgt_ni_ips" {
  type    = map(string)
  default = null
}

variable "subnet_cidrs" {
  type    = map(string)
  default = null
}

variable "ports" {
  type = map(string)
  default = {
    public  = "port1"
    private = "port2"
    mgtm    = "port3"
    ha_port = "port3"
  }
}

variable "mgmt_port" {
  type    = string
  default = "port3"
}
variable "public_port" {
  type    = string
  default = "port1"
}
variable "private_port" {
  type    = string
  default = "port2"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  type    = string
  default = "payg"
}

// license file for the active fgt
variable "license_file" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./licenses/license1.lic"
}

// FortiFlex tokens
variable "fortiflex_token" {
  type    = string
  default = ""
}

variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  type        = string
  default     = null
}

// SSH RSA public key for KeyPair if not exists
variable "rsa-public-key" {
  type    = string
  default = null
}

variable "backend-probe_port" {
  type    = string
  default = "8008"
}