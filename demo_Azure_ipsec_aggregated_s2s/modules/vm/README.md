# Terraform Module: Deployment of a simple linux virtual machine

This module IaC will deploy a VM server sample just mainly providing a network interface id and variables regarding location, resource group and so on. 

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.vm_ni](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.vm_ni_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | n/a | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | n/a | `string` | `"azureadmin"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | `"europe-west4"` | no |
| <a name="input_ni_ip"></a> [ni\_ip](#input\_ni\_ip) | Private IP | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Azure resourcers prefix description | `string` | `"terraform"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | `null` | no |
| <a name="input_rsa-public-key"></a> [rsa-public-key](#input\_rsa-public-key) | SSH RSA public key for KeyPair if not exists | `string` | `null` | no |
| <a name="input_storage-account_endpoint"></a> [storage-account\_endpoint](#input\_storage-account\_endpoint) | n/a | `string` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | Subnet CIDR | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure resourcers tags | `map(any)` | <pre>{<br>  "Deploy": "module-vms",<br>  "Project": "terraform-fortinet"<br>}</pre> | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | For testing VMs | `string` | `"Standard_B1ms"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm"></a> [vm](#output\_vm) | n/a |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | n/a |
| <a name="output_vm_username"></a> [vm\_username](#output\_vm\_username) | n/a |


# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.
