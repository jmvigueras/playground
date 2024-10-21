# Terraform Module: Fortigate bootstrap config

Create a Fortigate bootstrap configuration used as instance user-data. 

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
| [random_string.fgsp_auto-config_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.vpn_psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [template_file.fgt_1_faz-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_1_fmg-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_1_sdn-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_2_faz-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_2_fmg-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_2_sdn-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_active](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_ars-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_bgp-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_gwlb-vxlan-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_ha-fgcp-active-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_ha-fgcp-passive-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_ha-fgsp-active-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_ha-fgsp-passive-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_passive](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_sdwan-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_standalone-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_static-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_vhub-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_vpn-active-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_vpn-passive-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_vxlan-active-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_vxlan-passive-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.fgt_xlb-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | n/a | `string` | `"0.0.0.0/0"` | no |
| <a name="input_admin_port"></a> [admin\_port](#input\_admin\_port) | n/a | `string` | `"8443"` | no |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | n/a | `string` | `null` | no |
| <a name="input_bgp_asn_default"></a> [bgp\_asn\_default](#input\_bgp\_asn\_default) | ----------------------------------------------------------------------------------- Default BGP configuration ----------------------------------------------------------------------------------- | `string` | `"65000"` | no |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | n/a | `string` | `null` | no |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | n/a | `string` | `null` | no |
| <a name="input_cluster_pip"></a> [cluster\_pip](#input\_cluster\_pip) | n/a | `string` | `null` | no |
| <a name="input_config_ars"></a> [config\_ars](#input\_config\_ars) | ----------------------------------------------------------------------------------- Predefined variables to Azure Route Server - config\_ars   = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_faz"></a> [config\_faz](#input\_config\_faz) | ----------------------------------------------------------------------------------- Predefined variables for FAZ - config\_faz = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_fgcp"></a> [config\_fgcp](#input\_config\_fgcp) | ----------------------------------------------------------------------------------- Predefined variables for HA - config\_fgcp   = true (default) - confgi\_fgsp   = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_fgsp"></a> [config\_fgsp](#input\_config\_fgsp) | n/a | `bool` | `false` | no |
| <a name="input_config_fmg"></a> [config\_fmg](#input\_config\_fmg) | ----------------------------------------------------------------------------------- Predefined variables for FMG - config\_fmg = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_gwlb-vxlan"></a> [config\_gwlb-vxlan](#input\_config\_gwlb-vxlan) | ----------------------------------------------------------------------------------- Predefined variables for GWLB (VXLAN Azure) - config\_gwlb-vxlan = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_ha_port"></a> [config\_ha\_port](#input\_config\_ha\_port) | n/a | `bool` | `false` | no |
| <a name="input_config_hub"></a> [config\_hub](#input\_config\_hub) | ----------------------------------------------------------------------------------- Predefined variables for HUB vpn - config\_hub   = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_spoke"></a> [config\_spoke](#input\_config\_spoke) | ----------------------------------------------------------------------------------- Predefined variables for spoke config - config\_spoke   = true (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_vhub"></a> [config\_vhub](#input\_config\_vhub) | ----------------------------------------------------------------------------------- Predefined variables to vHUB connection - config\_vhub   = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_vxlan"></a> [config\_vxlan](#input\_config\_vxlan) | ----------------------------------------------------------------------------------- Predefined variables for HUB vxlan - config\_vxlan = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_config_xlb"></a> [config\_xlb](#input\_config\_xlb) | ----------------------------------------------------------------------------------- Variables for xLB - config\_xlb = false (default) ----------------------------------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_elb_ip"></a> [elb\_ip](#input\_elb\_ip) | n/a | `string` | `""` | no |
| <a name="input_faz_fgt-1_source-ip"></a> [faz\_fgt-1\_source-ip](#input\_faz\_fgt-1\_source-ip) | n/a | `string` | `""` | no |
| <a name="input_faz_fgt-2_source-ip"></a> [faz\_fgt-2\_source-ip](#input\_faz\_fgt-2\_source-ip) | n/a | `string` | `""` | no |
| <a name="input_faz_interface-select-method"></a> [faz\_interface-select-method](#input\_faz\_interface-select-method) | n/a | `string` | `""` | no |
| <a name="input_faz_ip"></a> [faz\_ip](#input\_faz\_ip) | n/a | `string` | `""` | no |
| <a name="input_faz_sn"></a> [faz\_sn](#input\_faz\_sn) | n/a | `string` | `""` | no |
| <a name="input_fgt-active-ni_ips"></a> [fgt-active-ni\_ips](#input\_fgt-active-ni\_ips) | n/a | `map(string)` | `null` | no |
| <a name="input_fgt-active-ni_names"></a> [fgt-active-ni\_names](#input\_fgt-active-ni\_names) | n/a | `map(string)` | `null` | no |
| <a name="input_fgt-passive-ni_ips"></a> [fgt-passive-ni\_ips](#input\_fgt-passive-ni\_ips) | n/a | `map(string)` | `null` | no |
| <a name="input_fgt-passive-ni_names"></a> [fgt-passive-ni\_names](#input\_fgt-passive-ni\_names) | n/a | `map(string)` | `null` | no |
| <a name="input_fgt_active_extra-config"></a> [fgt\_active\_extra-config](#input\_fgt\_active\_extra-config) | n/a | `string` | `""` | no |
| <a name="input_fgt_passive"></a> [fgt\_passive](#input\_fgt\_passive) | n/a | `bool` | `false` | no |
| <a name="input_fgt_passive_extra-config"></a> [fgt\_passive\_extra-config](#input\_fgt\_passive\_extra-config) | n/a | `string` | `""` | no |
| <a name="input_fmg_fgt-1_source-ip"></a> [fmg\_fgt-1\_source-ip](#input\_fmg\_fgt-1\_source-ip) | n/a | `string` | `""` | no |
| <a name="input_fmg_fgt-2_source-ip"></a> [fmg\_fgt-2\_source-ip](#input\_fmg\_fgt-2\_source-ip) | n/a | `string` | `""` | no |
| <a name="input_fmg_interface-select-method"></a> [fmg\_interface-select-method](#input\_fmg\_interface-select-method) | n/a | `string` | `""` | no |
| <a name="input_fmg_ip"></a> [fmg\_ip](#input\_fmg\_ip) | n/a | `string` | `""` | no |
| <a name="input_fmg_sn"></a> [fmg\_sn](#input\_fmg\_sn) | n/a | `string` | `""` | no |
| <a name="input_fortiflex_token_1"></a> [fortiflex\_token\_1](#input\_fortiflex\_token\_1) | FortiFlex tokens | `string` | `""` | no |
| <a name="input_fortiflex_token_2"></a> [fortiflex\_token\_2](#input\_fortiflex\_token\_2) | n/a | `string` | `""` | no |
| <a name="input_gwlb_ip"></a> [gwlb\_ip](#input\_gwlb\_ip) | n/a | `string` | `"172.30.3.15"` | no |
| <a name="input_gwlb_vxlan"></a> [gwlb\_vxlan](#input\_gwlb\_vxlan) | n/a | `map(string)` | <pre>{<br>  "port_ext": "10800",<br>  "port_int": "10801",<br>  "vdi_ext": "800",<br>  "vdi_int": "801"<br>}</pre> | no |
| <a name="input_ha_port"></a> [ha\_port](#input\_ha\_port) | n/a | `string` | `"port3"` | no |
| <a name="input_hub"></a> [hub](#input\_hub) | Variable to create a a VPN HUB public interface | `list(map(string))` | <pre>[<br>  {<br>    "bgp_asn_hub": "65000",<br>    "bgp_asn_spoke": "65000",<br>    "cidr": "172.30.0.0/24",<br>    "dpd_retryinterval": "5",<br>    "id": "HUB",<br>    "ike_version": "2",<br>    "local_gw": "",<br>    "mode_cfg": true,<br>    "network_id": "1",<br>    "vpn_cidr": "10.1.1.0/24",<br>    "vpn_port": "public",<br>    "vpn_psk": "secret-key-123"<br>  },<br>  {<br>    "bgp_asn_hub": "65000",<br>    "bgp_asn_spoke": "65000",<br>    "cidr": "172.30.0.0/24",<br>    "dpd_retryinterval": "5",<br>    "id": "HUB",<br>    "ike_version": "2",<br>    "local_gw": "",<br>    "mode_cfg": true,<br>    "network_id": "1",<br>    "vpn_cidr": "10.1.10.0/24",<br>    "vpn_port": "private",<br>    "vpn_psk": "secret-key-123"<br>  }<br>]</pre> | no |
| <a name="input_hub_peer_vxlan"></a> [hub\_peer\_vxlan](#input\_hub\_peer\_vxlan) | n/a | `list(map(string))` | <pre>[<br>  {<br>    "bgp_asn": "65000",<br>    "external_ip": "20.216.155.67",<br>    "local_ip": "10.0.3.1",<br>    "remote_ip": "10.0.3.2",<br>    "vni": "1100",<br>    "vxlan_port": "public"<br>  },<br>  {<br>    "bgp_asn": "65000",<br>    "external_ip": "172.30.0.106",<br>    "local_ip": "10.0.30.1",<br>    "remote_ip": "10.0.30.2",<br>    "vni": "1100",<br>    "vxlan_port": "private"<br>  }<br>]</pre> | no |
| <a name="input_hub_peer_vxlan_name"></a> [hub\_peer\_vxlan\_name](#input\_hub\_peer\_vxlan\_name) | n/a | `string` | `"vxlan"` | no |
| <a name="input_hubs"></a> [hubs](#input\_hubs) | Details to crate VPN connections | `list(map(string))` | <pre>[<br>  {<br>    "bgp_asn": "65000",<br>    "cidr": "172.20.30.0/24",<br>    "dpd_retryinterval": "5",<br>    "external_ip": "11.11.11.11",<br>    "hck_ip": "172.20.30.1",<br>    "hub_ip": "172.20.30.1",<br>    "id": "HUB",<br>    "ike_version": "2",<br>    "network_id": "1",<br>    "sdwan_port": "public",<br>    "site_ip": "172.20.30.10",<br>    "vpn_psk": "secret"<br>  }<br>]</pre> | no |
| <a name="input_ilb_ip"></a> [ilb\_ip](#input\_ilb\_ip) | n/a | `string` | `""` | no |
| <a name="input_license_file_1"></a> [license\_file\_1](#input\_license\_file\_1) | license file for the active fgt | `string` | `"./licenses/license1.lic"` | no |
| <a name="input_license_file_2"></a> [license\_file\_2](#input\_license\_file\_2) | license file for the passive fgt | `string` | `"./licenses/license2.lic"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License Type to create FortiGate-VM Provide the license type for FortiGate-VM Instances, either byol or payg. | `string` | `"payg"` | no |
| <a name="input_mgmt_port"></a> [mgmt\_port](#input\_mgmt\_port) | n/a | `string` | `"port3"` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | n/a | `map(string)` | <pre>{<br>  "ha_port": "port3",<br>  "mgtm": "port3",<br>  "private": "port2",<br>  "public": "port1"<br>}</pre> | no |
| <a name="input_private_port"></a> [private\_port](#input\_private\_port) | n/a | `string` | `"port2"` | no |
| <a name="input_public_port"></a> [public\_port](#input\_public\_port) | n/a | `string` | `"port1"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | `null` | no |
| <a name="input_route_table"></a> [route\_table](#input\_route\_table) | n/a | `string` | `null` | no |
| <a name="input_rs_bgp_asn"></a> [rs\_bgp\_asn](#input\_rs\_bgp\_asn) | n/a | `list(string)` | <pre>[<br>  "65515"<br>]</pre> | no |
| <a name="input_rs_peer"></a> [rs\_peer](#input\_rs\_peer) | Defalut values for Azure Route Server | `list(list(string))` | <pre>[<br>  [<br>    "172.30.100.132",<br>    "172.30.100.133"<br>  ],<br>  [<br>    "172.30.101.132",<br>    "172.30.101.133"<br>  ]<br>]</pre> | no |
| <a name="input_rsa-public-key"></a> [rsa-public-key](#input\_rsa-public-key) | SSH RSA public key for KeyPair if not exists | `string` | `null` | no |
| <a name="input_spoke"></a> [spoke](#input\_spoke) | Default parameters to configure a site | `map(any)` | <pre>{<br>  "bgp_asn": "65011",<br>  "cidr": "192.168.0.0/24",<br>  "id": "spoke"<br>}</pre> | no |
| <a name="input_subnet_cidrs"></a> [subnet\_cidrs](#input\_subnet\_cidrs) | n/a | `map(string)` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | ----------------------------------------------------------------------------------- | `string` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | n/a | `string` | `null` | no |
| <a name="input_vhub_bgp_asn"></a> [vhub\_bgp\_asn](#input\_vhub\_bgp\_asn) | n/a | `list(string)` | <pre>[<br>  "65515"<br>]</pre> | no |
| <a name="input_vhub_peer"></a> [vhub\_peer](#input\_vhub\_peer) | Defualt value for vHUB RouteServer | `list(string)` | <pre>[<br>  "10.0.252.68",<br>  "10.0.252.69"<br>]</pre> | no |
| <a name="input_vpc-spoke_cidr"></a> [vpc-spoke\_cidr](#input\_vpc-spoke\_cidr) | n/a | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key"></a> [api\_key](#output\_api\_key) | n/a |
| <a name="output_fgsp_auto-config_secret"></a> [fgsp\_auto-config\_secret](#output\_fgsp\_auto-config\_secret) | n/a |
| <a name="output_fgt_config_1"></a> [fgt\_config\_1](#output\_fgt\_config\_1) | n/a |
| <a name="output_fgt_config_2"></a> [fgt\_config\_2](#output\_fgt\_config\_2) | n/a |
| <a name="output_vpn_psk"></a> [vpn\_psk](#output\_vpn\_psk) | n/a |