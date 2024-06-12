# Terraform Module: Create Fortigate VPCs

Create VPC for fortigate instances wihin GCP

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow-bastion-vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-mgmt-fgt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-private-fgt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-public-fgt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.vpc_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network.vpc_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network.vpc_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.subnet_bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.subnet_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.subnet_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.subnet_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.subnet_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | Fortigates Admin CIDR to create Firewall rules | `string` | `"0.0.0.0/0"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | GCP resourcers prefix description | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | `"europe-west4"` | no |
| <a name="input_vpc-sec_cidr"></a> [vpc-sec\_cidr](#input\_vpc-sec\_cidr) | VPC CIDR | `string` | `"172.30.0.0/23"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_faz_ni_ips"></a> [faz\_ni\_ips](#output\_faz\_ni\_ips) | Map of reserved IPs for FAZ |
| <a name="output_fgt-active-ni_ips"></a> [fgt-active-ni\_ips](#output\_fgt-active-ni\_ips) | Fortigate instance cluster member 1 map of IPs |
| <a name="output_fgt-passive-ni_ips"></a> [fgt-passive-ni\_ips](#output\_fgt-passive-ni\_ips) | Fortigate instance cluster member 2 map of IPs |
| <a name="output_fmg_ni_ips"></a> [fmg\_ni\_ips](#output\_fmg\_ni\_ips) | Map of reserved IPs for FMG |
| <a name="output_ilb_ip"></a> [ilb\_ip](#output\_ilb\_ip) | Internal LB IP |
| <a name="output_ncc_private_ips"></a> [ncc\_private\_ips](#output\_ncc\_private\_ips) | Network Connectivity Center IPs within internal subnet |
| <a name="output_ncc_public_ips"></a> [ncc\_public\_ips](#output\_ncc\_public\_ips) | Network Connectivity Center IPs within public subnet |
| <a name="output_subnet_cidrs"></a> [subnet\_cidrs](#output\_subnet\_cidrs) | List of subnets CIDRs |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | List of subnets IDs |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | List of subnets names |
| <a name="output_subnet_self_links"></a> [subnet\_self\_links](#output\_subnet\_self\_links) | List of subnets SelfLink |
| <a name="output_vpc_ids"></a> [vpc\_ids](#output\_vpc\_ids) | Map of VPC IDs |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | Map of VPC names |
| <a name="output_vpc_self_links"></a> [vpc\_self\_links](#output\_vpc\_self\_links) | Map of VPC SelfLink |
<!-- END_TF_DOCS -->