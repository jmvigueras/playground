# Terraform module: Azure LoadBalancers

This module IaC is a part of a full deployment of a Fortigate cluster in a sandwich configuration. This terraform code will deploy an External Load Balancer (ELB), Internal Load Balancer (ILB) and Gateway Load Balancer (GWLB). It is only necessary an external and internal loadbalancer for a Fortigatet cluster, but GWLB it is also deployed for demo purpose.  

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
| [azurerm_lb.elb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb.gwlb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb.ilb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.elb_backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_backend_address_pool.gwlb_backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_backend_address_pool.ilb_backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_backend_address_pool_address.elb_backend_fgt_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) | resource |
| [azurerm_lb_backend_address_pool_address.elb_backend_fgt_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) | resource |
| [azurerm_lb_backend_address_pool_address.gwlb_backend_fgt_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) | resource |
| [azurerm_lb_backend_address_pool_address.gwlb_backend_fgt_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) | resource |
| [azurerm_lb_backend_address_pool_address.ilb_backend_fgt_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) | resource |
| [azurerm_lb_backend_address_pool_address.ilb_backend_fgt_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) | resource |
| [azurerm_lb_probe.elb_probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_probe.gwlb_probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_probe.ilb_probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.elb_listeners](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_lb_rule.gwlb_rule_haport](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_lb_rule.ilb_rule_haport](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_public_ip.elb_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend-probe_port"></a> [backend-probe\_port](#input\_backend-probe\_port) | Fortigate interface probe port | `string` | `"8008"` | no |
| <a name="input_config_gwlb"></a> [config\_gwlb](#input\_config\_gwlb) | Region for deployment | `bool` | `false` | no |
| <a name="input_elb_floating_ip"></a> [elb\_floating\_ip](#input\_elb\_floating\_ip) | Floating IPs | `bool` | `false` | no |
| <a name="input_elb_listeners"></a> [elb\_listeners](#input\_elb\_listeners) | List of ports to open (listernes) | `map(string)` | <pre>{<br>  "443": "Tcp",<br>  "4500": "Udp",<br>  "4789": "Udp",<br>  "500": "Udp",<br>  "80": "Tcp"<br>}</pre> | no |
| <a name="input_fgt-active-ni_ips"></a> [fgt-active-ni\_ips](#input\_fgt-active-ni\_ips) | Fortigate IPs | `map(string)` | `null` | no |
| <a name="input_fgt-passive-ni_ips"></a> [fgt-passive-ni\_ips](#input\_fgt-passive-ni\_ips) | n/a | `map(string)` | `null` | no |
| <a name="input_gwlb_ip"></a> [gwlb\_ip](#input\_gwlb\_ip) | n/a | `string` | `null` | no |
| <a name="input_gwlb_vxlan"></a> [gwlb\_vxlan](#input\_gwlb\_vxlan) | Fortigate vxlan vdi and port config | `map(string)` | <pre>{<br>  "port_ext": "10800",<br>  "port_int": "10801",<br>  "vdi_ext": "800",<br>  "vdi_int": "801"<br>}</pre> | no |
| <a name="input_ilb_floating_ip"></a> [ilb\_floating\_ip](#input\_ilb\_floating\_ip) | n/a | `bool` | `false` | no |
| <a name="input_ilb_ip"></a> [ilb\_ip](#input\_ilb\_ip) | n/a | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Region for deployment | `string` | `"francecentral"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Azure resourcers prefix description added in name | `string` | `"terraform"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | `null` | no |
| <a name="input_subnet_cidrs"></a> [subnet\_cidrs](#input\_subnet\_cidrs) | Map of subnet CIDRS VNet FGT | `map(string)` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Map of subnet IDs VNet FGT | `map(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure resourcers tags | `map(string)` | <pre>{<br>  "deploy": "module-xlb"<br>}</pre> | no |
| <a name="input_vnet-fgt"></a> [vnet-fgt](#input\_vnet-fgt) | VNET ID of FGT VNET for peering | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elb_public-ip"></a> [elb\_public-ip](#output\_elb\_public-ip) | n/a |
| <a name="output_gwlb_frontip_config_id"></a> [gwlb\_frontip\_config\_id](#output\_gwlb\_frontip\_config\_id) | n/a |
| <a name="output_gwlb_ip"></a> [gwlb\_ip](#output\_gwlb\_ip) | n/a |
| <a name="output_ilb_private-ip"></a> [ilb\_private-ip](#output\_ilb\_private-ip) | n/a |
<!-- END_TF_DOCS -->

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.