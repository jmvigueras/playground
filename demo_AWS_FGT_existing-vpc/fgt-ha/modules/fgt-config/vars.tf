#-----------------------------------------------------------------------------------
# Predefined variables for HA
# - config_fgcp   = true (default)
# - confgi_fgsp   = false (default)
#-----------------------------------------------------------------------------------
variable "config_fgcp" {
  type    = bool
  default = false
}
variable "config_fgsp" {
  type    = bool
  default = false
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
    id      = "spoke-1"
    cidr    = "192.168.0.0/24"
    bgp-asn = "65011"
  }
}

// Details to crate VPN connections
variable "hubs" {
  type = list(map(string))
  default = [
    {
      id                = "HUB1"
      bgp-asn           = "65001"
      public-ip         = "11.11.11.11"
      hub-ip            = "172.20.30.1"
      site-ip           = "172.20.30.10" // set to "" if VPN mode-cfg is enable
      hck-srv-ip        = "172.20.30.1"
      vpn_psk           = "secret"
      cidr              = "172.20.30.0/24"
      ike-version       = "2"
      network_id        = "1"
      dpd-retryinterval = "5"
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

// Variable to create a a VPN HUB
variable "hub" {
  type = map(any)
  default = {
    id                = "HUB-AWS"
    bgp-asn_hub       = "65002"
    bgp-asn_spoke     = "65011"
    vpn_cidr          = "10.10.10.0/24"
    vpn_psk           = "secret-key-123"
    cidr              = "192.168.0.0/24"
    ike-version       = "2"
    network_id        = "1"
    dpd-retryinterval = "5"
    mode-cfg          = true
  }
}

variable "config_vxlan" {
  type    = bool
  default = false
}

// Details for vxlan connection to hub (simulated L2/MPLS)
variable "hub-peer_vxlan" {
  type = map(string)
  default = {
    bgp-asn   = "65001"
    public-ip = "" // leave in blank if you don't know public IP jet
    remote-ip = "10.10.30.1"
    local-ip  = "10.10.30.2"
    vni       = "1100"
  }
}

#-----------------------------------------------------------------------------------
# Predefined variables for TGW (GRE connection)
# - config_tgw-gre   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_tgw-gre" {
  type    = bool
  default = false
}

variable "tgw_cidr" {
  type    = list(string)
  default = ["172.20.10.0/24"]
}

variable "tgw_inside_cidr" {
  type    = list(string)
  default = ["169.254.100.0/29", "169.254.101.0/29"]
}

variable "tgw_bgp-asn" {
  type    = string
  default = "65515"
}

#-----------------------------------------------------------------------------------
# Predefined variables for GWLB (GENEVE connection)
# - config_gwlb-geneve = false (default) 
#-----------------------------------------------------------------------------------
variable "config_gwlb-geneve" {
  type    = bool
  default = false
}

variable "gwlbe_ip" {
  type    = list(string)
  default = ["172.20.0.66", "172.20.0.194"]
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

variable "fgt_passive" {
  type    = bool
  default = false
}

variable "fgt_passive_extra-config" {
  type    = string
  default = ""
}

variable "fgt_active_extra-config" {
  type    = string
  default = ""
}

variable "vpc-spoke_cidr" {
  type    = list(string)
  default = null
}

variable "fgt-active-ni_ips" {
  type    = map(string)
  default = null
}

variable "fgt-passive-ni_ips" {
  type    = map(string)
  default = null
}

variable "subnet_active_cidrs" {
  type    = map(string)
  default = null
}

variable "subnet_passive_cidrs" {
  type    = map(string)
  default = null
}

variable "mgmt_port" {
  type    = string
  default = "port1"
}
variable "public_port" {
  type    = string
  default = "port2"
}
variable "private_port" {
  type    = string
  default = "port3"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  type    = string
  default = "payg"
}

// license file for the active fgt
variable "license_file_1" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./licenses/license1.lic"
}

// license file for the passive fgt
variable "license_file_2" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "./licenses/license2.lic"
}

variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  type      = string
  default   = null
}

// SSH RSA public key for KeyPair if not exists
variable "rsa-public-key" {
  type    = string
  default = null
}