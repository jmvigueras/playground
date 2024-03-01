# Terraform Module: Fortigate bootstrap configuration

Create Fortigate config using provided inputs.

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix      = "test"
  azs         = ["eu-west-1a","eu-west-1b"]

  hub = [
    {
      id                = "HUB"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.1.1.0/24"
      vpn_psk           = "secret"
      cidr              = "172.20.0.0/24"
      ike_version       = "2"  // if skipped "2"
      network_id        = "1"  // if skipped "1"
      dpd_retryinterval = "10"  // if skipped "10"
      mode_cfg          = true
      vpn_port          = "public"
    }
  ]

  spoke = {
    id      = "fgt"
    cidr    = "172.30.0.0/23"
    bgp_asn = "65000"
  }
  hubs = [
    {
      id                = "HUB"
      bgp_asn           = "65000"
      external_ip       = "11.11.11.11" // leave in blank if use external_fqdn
      external_fqdn     = "hub-vpn.example.com" // leave in blank if use external_ip
      hub_ip            = "172.20.30.1"
      site_ip           = "172.20.30.10" // leave in blank if mode_cfg true
      hck_ip            = "172.20.30.1"
      vpn_psk           = "secret"
      cidr              = "172.20.30.0/24"
      ike_version       = "2"  // if skipped "2"
      network_id        = "1"  // if skipped "1"
      dpd_retryinterval = "5"  // if skipped "5"
      sdwan_port        = "public"
    }
  ]
  vxlan_peers = [
    {
      external_ip    = "11.11.11.22,11.11.11.23" //you should use comma separted IPs
      remote_ip      = "10.10.30.2,10.10.30.3" //you should use comma separted IPs
      local_ip       = "10.10.30.1"
      bgp_asn        = "65000"
      vni            = "1100"
      vxlan_port     = "private"
    }
  ]
  # (It is possible to use fgt_ports_config output from module fgt_ni_sg)
  fgt_ports_config = {
    "az1.fgt1" = [
      {
        gw   = "172.30.0.1"
        ip   = "172.30.0.10"
        mask = "255.255.255.240"
        port = "port1"
        tag  = "public"
        },
      {
        gw   = "172.30.0.97"
        ip   = "172.30.0.106"
        mask = "255.255.255.240"
        port = "port2"
        tag  = "private"
      },
      {
        gw   = "172.30.0.129"
        ip   = "172.30.0.148"
        mask = "255.255.255.240"
        port = "port3"
        tag  = "mgmt"
      },
    ]
    "az1.fgt2" = [
      {
        gw   = "172.30.0.1"
        ip   = "172.30.0.11"
        mask = "255.255.255.240"
        port = "port1"
        tag  = "public"
        },
      {
        gw   = "172.30.0.97"
        ip   = "172.30.0.107"
        mask = "255.255.255.240"
        port = "port2"
        tag  = "private"
      },
      {
        gw   = "172.30.0.129"
        ip   = "172.30.0.149"
        mask = "255.255.255.240"
        port = "port3"
        tag  = "mgmt"
      },
    ]
  }
  # (It is possible to use fgt_ips_map output from module fgt_ni_sg)
  fgt_ips_map = {
    "az1.fgt1" = {
      port1.public  = "172.30.0.10"
      port2.private = "172.30.0.106"
      port3.mgmt    = "172.30.0.148"
    }
    "az1.fgt2" = {
      port1.public  = "172.30.0.11"
      port2.private = "172.30.0.107"
      port3.mgmt    = "172.30.0.149"
    }
  }
  
  tgw_bgp_asn = "65515"
  tgw_cidr    = "172.30.110.0/24"

  tgw_gre_peer = { for i, k in keys(local.fgt_ports_config) : k =>
    { tgw_ip        = cidrhost(local.hub1_tgw_cidr , 10 + i)
      inside_cidr   = "169.254.${i + 101}.0/24"
      twg_bgp_asn   = local.tgw_bgp-asn
      route_map_out = "rm_out_hub_to_external_0" //created by default prepend routes with community 65001:10
      route_map_in  = ""
      gre_name      = "gre-to-tgw"
    }
  }
}

module "example" {
  for_each = { for k, v in local.fgt_ports_config : k => v }
  source = "../fgt_config"

  fgt_id               = each.key
  admin_cidr           = "0.0.0.0/0"
  admin_port           = "8443"
  api_key              = "5tvsi5rnnk7afj4fjoapy8sicegcpk"
  rsa_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeKBg..."

  static_route_cidrs = ["10.1.0.0/16"]
  ports_config = each.value

  license_type    = "byol"
  fortiflex_token = "C320816FD514572974X4"

  config_spoke = true
  spoke        = local.spoke
  hubs         = local.hubs

  config_vxlan = true
  vxlan_peers  = local.vxlan_peers

  config_tgw_gre  = true
  tgw_gre_peer    = local.tgw_gre_peer[each.key]

  config_fmg = true
  fmg_ip     = "172.20.10.25"
  fmg_sn     = "SN12345679"

  config_faz = true
  faz_ip     = "172.20.10.26"
  faz_sn     = "SN12345679"

  config_fgcp = true
  fgcp_port   = "mgmt"
  ha_members  = local.fgt_ports_config
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_string.api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.vpn_psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [template_file.config_auto_scale](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_basic](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_bgp](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_faz](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_fgcp](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_fgsp](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_fgsp_peers](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_fmg](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_fw_policy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_gwlb](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_interfaces](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_route](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_s2s](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_sdn](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_sdwan](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_tgw_gre](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_vpn](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_vxlan](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.config_vxlan_bgp](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | CIDR range where fortigate can be administrate | `string` | `"0.0.0.0/0"` | no |
| <a name="input_admin_port"></a> [admin\_port](#input\_admin\_port) | Fortigate administration port | `string` | `"8443"` | no |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | Fortigate API Key to remote admin | `string` | `null` | no |
| <a name="input_auto_scale_secret"></a> [auto\_scale\_secret](#input\_auto\_scale\_secret) | Fortigate auto scale password | `string` | `"nh62znfkzajz2o9"` | no |
| <a name="input_auto_scale_sync_port"></a> [auto\_scale\_sync\_port](#input\_auto\_scale\_sync\_port) | Type of port used to sync config betweewn fortigates | `string` | `"private"` | no |
| <a name="input_backend_probe_port"></a> [backend\_probe\_port](#input\_backend\_probe\_port) | Backend probe port if configuring NLB or ALB | `string` | `"8008"` | no |
| <a name="input_bgp_asn_default"></a> [bgp\_asn\_default](#input\_bgp\_asn\_default) | Default BGP ASN | `string` | `"65000"` | no |
| <a name="input_config_auto_scale"></a> [config\_auto\_scale](#input\_config\_auto\_scale) | Boolean variable to configure auto-scale sync config between fortigates | `bool` | `false` | no |
| <a name="input_config_extra"></a> [config\_extra](#input\_config\_extra) | Add extra config to bootstrap config generated | `string` | `""` | no |
| <a name="input_config_faz"></a> [config\_faz](#input\_config\_faz) | Boolean varible to configure FortiManger | `bool` | `false` | no |
| <a name="input_config_fgcp"></a> [config\_fgcp](#input\_config\_fgcp) | Boolean varible to configure FortiGate Cluster type FGCP | `bool` | `false` | no |
| <a name="input_config_fgsp"></a> [config\_fgsp](#input\_config\_fgsp) | Boolean varible to configure FortiGate Cluster type FGSP | `bool` | `false` | no |
| <a name="input_config_fmg"></a> [config\_fmg](#input\_config\_fmg) | Boolean varible to configure FortiManger | `bool` | `false` | no |
| <a name="input_config_fw_policy"></a> [config\_fw\_policy](#input\_config\_fw\_policy) | Boolean variable to configure basic allow all policies | `bool` | `true` | no |
| <a name="input_config_gwlb"></a> [config\_gwlb](#input\_config\_gwlb) | Boolean varible to configure GENEVE tunnels to a AWS GWLB | `bool` | `false` | no |
| <a name="input_config_hub"></a> [config\_hub](#input\_config\_hub) | Boolean varible to configure fortigate as a SDWAN HUB | `bool` | `false` | no |
| <a name="input_config_s2s"></a> [config\_s2s](#input\_config\_s2s) | Boolean varible to configure IPSEC site to site connections | `bool` | `false` | no |
| <a name="input_config_spoke"></a> [config\_spoke](#input\_config\_spoke) | Boolean varible to configure fortigate as SDWAN spoke | `bool` | `false` | no |
| <a name="input_config_tgw_gre"></a> [config\_tgw\_gre](#input\_config\_tgw\_gre) | Boolean varible to configure TGW GRE tunnels to a AWS TGW | `bool` | `false` | no |
| <a name="input_config_vxlan"></a> [config\_vxlan](#input\_config\_vxlan) | Boolean varible to configure VXLAN connections | `bool` | `false` | no |
| <a name="input_faz_fgt_source_ip"></a> [faz\_fgt\_source\_ip](#input\_faz\_fgt\_source\_ip) | Fortigate source IP used to connect with FortiAnalyzer | `string` | `""` | no |
| <a name="input_faz_interface_select_method"></a> [faz\_interface\_select\_method](#input\_faz\_interface\_select\_method) | Fortigate interface select method to connect to FortiManager | `string` | `""` | no |
| <a name="input_faz_ip"></a> [faz\_ip](#input\_faz\_ip) | FortiAnaluzer IP | `string` | `""` | no |
| <a name="input_faz_sn"></a> [faz\_sn](#input\_faz\_sn) | FortiAnalyzer SN | `string` | `""` | no |
| <a name="input_fgcp_port"></a> [fgcp\_port](#input\_fgcp\_port) | Type of port used to sync with other members of cluster in FGCP type | `string` | `"mgmt"` | no |
| <a name="input_fgsp_port"></a> [fgsp\_port](#input\_fgsp\_port) | Type of port used to sync with other members of cluster in FGSP type | `string` | `"private"` | no |
| <a name="input_fgt_id"></a> [fgt\_id](#input\_fgt\_id) | Fortigate name | `string` | `"az1.fgt1"` | no |
| <a name="input_fgt_id_prefix"></a> [fgt\_id\_prefix](#input\_fgt\_id\_prefix) | Fortigate name prefix | `string` | `"fgt"` | no |
| <a name="input_fmg_fgt_source_ip"></a> [fmg\_fgt\_source\_ip](#input\_fmg\_fgt\_source\_ip) | Fortigate source IP used to connect with Fortimanager | `string` | `""` | no |
| <a name="input_fmg_interface_select_method"></a> [fmg\_interface\_select\_method](#input\_fmg\_interface\_select\_method) | Fortigate interface select method to connect to FortiManager | `string` | `""` | no |
| <a name="input_fmg_ip"></a> [fmg\_ip](#input\_fmg\_ip) | FortiManager IP | `string` | `""` | no |
| <a name="input_fmg_sn"></a> [fmg\_sn](#input\_fmg\_sn) | FortiManager SN | `string` | `""` | no |
| <a name="input_fortiflex_token"></a> [fortiflex\_token](#input\_fortiflex\_token) | FortiFlex token | `string` | `""` | no |
| <a name="input_gwlb_inspection_cidrs"></a> [gwlb\_inspection\_cidrs](#input\_gwlb\_inspection\_cidrs) | List of inspection CIRDS, used to create policy route maps | `list(string)` | <pre>[<br>  "192.168.0.0/16",<br>  "10.0.0.0/8",<br>  "172.16.0.0/12"<br>]</pre> | no |
| <a name="input_gwlbe_ip"></a> [gwlbe\_ip](#input\_gwlbe\_ip) | GWLB IP to create GENEVE tunnel | `string` | `""` | no |
| <a name="input_ha_master_id"></a> [ha\_master\_id](#input\_ha\_master\_id) | Name of fortigate instance acting as master of the cluster | `string` | `"az1.fgt1"` | no |
| <a name="input_ha_members"></a> [ha\_members](#input\_ha\_members) | Map of string with details of cluster members | `map(list(map(string)))` | `{}` | no |
| <a name="input_hub"></a> [hub](#input\_hub) | Map of string with details to create VPN HUB | `list(map(string))` | <pre>[<br>  {<br>    "bgp_asn_hub": "65000",<br>    "bgp_asn_spoke": "65000",<br>    "cidr": "172.30.0.0/24",<br>    "dpd_retryinterval": "5",<br>    "id": "HUB",<br>    "ike_version": "2",<br>    "mode_cfg": true,<br>    "network_id": "1",<br>    "vpn_cidr": "10.1.1.0/24",<br>    "vpn_port": "public",<br>    "vpn_psk": "secret-key-123"<br>  }<br>]</pre> | no |
| <a name="input_hubs"></a> [hubs](#input\_hubs) | Details to crate VPN connections and SDWAN config | `list(map(string))` | <pre>[<br>  {<br>    "bgp_asn": "65000",<br>    "cidr": "172.20.30.0/24",<br>    "dpd_retryinterval": "5",<br>    "external_fqdn": "hub-vpn.example.com",<br>    "external_ip": "11.11.11.11",<br>    "hck_ip": "172.20.30.1",<br>    "hub_ip": "172.20.30.1",<br>    "id": "HUB",<br>    "ike_version": "2",<br>    "network_id": "1",<br>    "sdwan_port": "public",<br>    "site_ip": "172.20.30.10",<br>    "vpn_psk": "secret"<br>  }<br>]</pre> | no |
| <a name="input_license_file"></a> [license\_file](#input\_license\_file) | License file path for the active fgt | `string` | `"./licenses/license1.lic"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License Type to create FortiGate-VM | `string` | `"payg"` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | Map of type of port and their assignations | `map(string)` | <pre>{<br>  "ha": "port3",<br>  "mgtm": "port3",<br>  "private": "port2",<br>  "public": "port1"<br>}</pre> | no |
| <a name="input_ports_config"></a> [ports\_config](#input\_ports\_config) | List of maps of ports details | `list(map(string))` | `[]` | no |
| <a name="input_rsa_public_key"></a> [rsa\_public\_key](#input\_rsa\_public\_key) | SSH RSA public key for KeyPair | `string` | `null` | no |
| <a name="input_s2s_peers"></a> [s2s\_peers](#input\_s2s\_peers) | Details for site to site connections beteween fortigates | `list(map(string))` | <pre>[<br>  {<br>    "bgp_asn_remote": "65000",<br>    "dpd_retryinterval": "5",<br>    "hck_ip": "10.10.10.2",<br>    "id": "s2s",<br>    "ike_version": "2",<br>    "network_id": "11",<br>    "remote_cidr": "172.20.0.0/24",<br>    "remote_gw": "11.11.11.22",<br>    "vpn_cidr": "10.10.10.0/27",<br>    "vpn_local_ip": "10.10.10.1",<br>    "vpn_port": "public",<br>    "vpn_psk": "secret-key",<br>    "vpn_remote_ip": "10.10.10.2"<br>  }<br>]</pre> | no |
| <a name="input_spoke"></a> [spoke](#input\_spoke) | Default parameters to configure a site | `map(any)` | <pre>{<br>  "bgp_asn": "65000",<br>  "cidr": "172.30.0.0/23",<br>  "id": "fgt"<br>}</pre> | no |
| <a name="input_static_route_cidrs"></a> [static\_route\_cidrs](#input\_static\_route\_cidrs) | List of CIDRs to add as static routes | `list(string)` | `null` | no |
| <a name="input_tgw_gre_peer"></a> [tgw\_gre\_peer](#input\_tgw\_gre\_peer) | Details to create a GRE tunnel to a AWS TGW | `map(string)` | <pre>{<br>  "gre_name": "gre-to-tgw",<br>  "inside_cidr": "169.254.101.0/29",<br>  "route_map_in": "",<br>  "route_map_out": "",<br>  "tgw_bgp_asn": "65011",<br>  "tgw_ip": "172.20.10.10"<br>}</pre> | no |
| <a name="input_vxlan_peers"></a> [vxlan\_peers](#input\_vxlan\_peers) | Details for vxlan connections beteween fortigates | `list(map(string))` | <pre>[<br>  {<br>    "bgp_asn": "65000",<br>    "external_ip": "11.11.11.22,11.11.11.23",<br>    "local_ip": "10.10.30.1",<br>    "remote_ip": "10.10.30.2,10.10.30.3",<br>    "route_map_in": "",<br>    "route_map_out": "",<br>    "vni": "1100",<br>    "vxlan_port": "private"<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key"></a> [api\_key](#output\_api\_key) | API Key for FortiGate instance |
| <a name="output_fgt_config"></a> [fgt\_config](#output\_fgt\_config) | FortiGate configuration output |
| <a name="output_vpn_psk"></a> [vpn\_psk](#output\_vpn\_psk) | VPN Pre-Shared Key (PSK) |
<!-- END_TF_DOCS -->