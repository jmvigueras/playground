# Terraform module: VNET for a Fortigate Cluster

This module IaC is a part of a full deployment of a Fortigate cluster. This terraform code will deploy all necessary componets of a fortigate cluster. The deplyoment include subnets: mgmt-ha, public and private for fortigate interfaces and aditional subnets for future deployment of a VirtualGateway and Azure Router Server. Network interfaces for fortigates are created and related Network Security Groups. 

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.ni-active-mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.ni-active-private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.ni-active-public_sdn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.ni-active-public_xlb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.ni-passive-mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.ni-passive-private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.ni-passive-public_fgsp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.ni-passive-public_xlb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.ni-active-mgmt-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.ni-active-public-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.ni-passive-mgmt-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.ni-passive-public-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.nsg-mgmt-ha](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg-private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg-public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg-public-default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg_bastion_admin_cidr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg_bastion_default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.nsr-egress-mgmt-ha-all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-egress-private-all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-egress-public-all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-egress-public-default-allow-all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-mgmt-ha-fmg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-mgmt-ha-https](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-mgmt-ha-ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-mgmt-ha-sync](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-private-all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-public-default-allow-all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-public-icmp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-public-ipsec-4500](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-public-ipsec-500](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr-ingress-public-vxlan-4789](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr_bastion_admin_cidr_egress_allow_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr_bastion_admin_cidr_ingress_allow_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr_bastion_default_egress_allow_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.nsr_bastion_default_ingress_allow_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.active-mgmt-ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.active-public-ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.passive-mgmt-ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.passive-public-ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_route_table.rt-bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.subnet-bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet-hamgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet-private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet-public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet-routeserver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet-vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.subnet-private-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.subnet-public-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.subnet_bastion_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.rta-spoke-1-subnet-1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.vnet-fgt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerate"></a> [accelerate](#input\_accelerate) | Boolean viriable to config accelerated interfaces | `bool` | `true` | no |
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | n/a | `string` | `"0.0.0.0/0"` | no |
| <a name="input_admin_port"></a> [admin\_port](#input\_admin\_port) | HTTPS Port | `string` | `"8443"` | no |
| <a name="input_config_fgsp"></a> [config\_fgsp](#input\_config\_fgsp) | n/a | `bool` | `false` | no |
| <a name="input_config_xlb"></a> [config\_xlb](#input\_config\_xlb) | n/a | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Region for deployment | `string` | `"francecentral"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Azure resourcers prefix description added in name | `string` | `"module-vnet-fgt"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Azure resourcers group | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure resourcers tags | `map(any)` | <pre>{<br>  "deploy": "module-vnet-fgt"<br>}</pre> | no |
| <a name="input_vnet-fgt_cidr"></a> [vnet-fgt\_cidr](#input\_vnet-fgt\_cidr) | CIDR range for VNET Fortigate - Security VNET | `string` | `"172.30.0.0/23"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fgt-active-mgmt-ip"></a> [fgt-active-mgmt-ip](#output\_fgt-active-mgmt-ip) | n/a |
| <a name="output_fgt-active-ni_ids"></a> [fgt-active-ni\_ids](#output\_fgt-active-ni\_ids) | n/a |
| <a name="output_fgt-active-ni_ips"></a> [fgt-active-ni\_ips](#output\_fgt-active-ni\_ips) | n/a |
| <a name="output_fgt-active-ni_names"></a> [fgt-active-ni\_names](#output\_fgt-active-ni\_names) | n/a |
| <a name="output_fgt-active-public-ip"></a> [fgt-active-public-ip](#output\_fgt-active-public-ip) | n/a |
| <a name="output_fgt-active-public-name"></a> [fgt-active-public-name](#output\_fgt-active-public-name) | n/a |
| <a name="output_fgt-passive-mgmt-ip"></a> [fgt-passive-mgmt-ip](#output\_fgt-passive-mgmt-ip) | n/a |
| <a name="output_fgt-passive-ni_ids"></a> [fgt-passive-ni\_ids](#output\_fgt-passive-ni\_ids) | n/a |
| <a name="output_fgt-passive-ni_ips"></a> [fgt-passive-ni\_ips](#output\_fgt-passive-ni\_ips) | n/a |
| <a name="output_fgt-passive-ni_names"></a> [fgt-passive-ni\_names](#output\_fgt-passive-ni\_names) | n/a |
| <a name="output_fgt-passive-public-ip"></a> [fgt-passive-public-ip](#output\_fgt-passive-public-ip) | n/a |
| <a name="output_fgt-passive-public-name"></a> [fgt-passive-public-name](#output\_fgt-passive-public-name) | n/a |
| <a name="output_nsg-mgmt-ha_id"></a> [nsg-mgmt-ha\_id](#output\_nsg-mgmt-ha\_id) | n/a |
| <a name="output_nsg-private_id"></a> [nsg-private\_id](#output\_nsg-private\_id) | n/a |
| <a name="output_nsg-public_id"></a> [nsg-public\_id](#output\_nsg-public\_id) | n/a |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | n/a |
| <a name="output_subnet_cidrs"></a> [subnet\_cidrs](#output\_subnet\_cidrs) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | n/a |
| <a name="output_vnet"></a> [vnet](#output\_vnet) | n/a |
| <a name="output_vnet_names"></a> [vnet\_names](#output\_vnet\_names) | n/a |
<!-- END_TF_DOCS -->

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.
