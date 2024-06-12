# Terraform Module: Network Connectivity Center

Create a Network Connectivity Center instance wihin GCP

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
| [google_compute_router.ncc_cloud-router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_interface.ncc_cloud-router_nic-0](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_interface.ncc_cloud-router_nic-1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_peer.router-private-peer_active_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_compute_router_peer.router-private-peer_active_2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_compute_router_peer.router-private-peer_passive_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_compute_router_peer.router-private-peer_passive_2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_network_connectivity_hub.ncc_hub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_connectivity_hub) | resource |
| [google_network_connectivity_spoke.hub_spoke_fgt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_connectivity_spoke) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_fgt-active-ni_ip"></a> [fgt-active-ni\_ip](#input\_fgt-active-ni\_ip) | Fortigate instance cluster member 1 IP, used to create Network Appliance | `string` | n/a | yes |
| <a name="input_fgt-passive-ni_ip"></a> [fgt-passive-ni\_ip](#input\_fgt-passive-ni\_ip) | Fortigate instance cluster member 2 IP, used to create Network Appliance | `string` | n/a | yes |
| <a name="input_fgt_active_self_link"></a> [fgt\_active\_self\_link](#input\_fgt\_active\_self\_link) | Fortigate instance cluster member 1 SelfLink, used to create Network Appliance | `string` | n/a | yes |
| <a name="input_fgt_bgp-asn"></a> [fgt\_bgp-asn](#input\_fgt\_bgp-asn) | Fortigate instances BGP ASN | `string` | `"65000"` | no |
| <a name="input_fgt_passive"></a> [fgt\_passive](#input\_fgt\_passive) | Boolean used to create compute router peer to fortigate instance cluster member 2 | `bool` | `false` | no |
| <a name="input_fgt_passive_self_link"></a> [fgt\_passive\_self\_link](#input\_fgt\_passive\_self\_link) | Fortigate instance cluster member 2 SelfLink, used to create Network Appliance | `string` | n/a | yes |
| <a name="input_ncc_bgp-asn"></a> [ncc\_bgp-asn](#input\_ncc\_bgp-asn) | NCC BGP ASN | `string` | `"65515"` | no |
| <a name="input_ncc_ips"></a> [ncc\_ips](#input\_ncc\_ips) | List of NCC private IPs | `list(string)` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | GCP resourcers prefix description | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP region to deploy | `string` | `"europe-west4"` | no |
| <a name="input_subnet_self_link"></a> [subnet\_self\_link](#input\_subnet\_self\_link) | Subnet SelfLink to create Cloud Router interfaces | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC name to create Cloud Router | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->