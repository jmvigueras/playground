# Terraform Module: Fortigate cluster

Create a Fortigate cluster instances wihin Azure Cloud

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
| [azurerm_virtual_machine.fgt-1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine.fgt-2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerate"></a> [accelerate](#input\_accelerate) | enable accelerate network, either true or false, default is false Make the the instance choosed supports accelerated networking. Check: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-vm-instances | `string` | `"false"` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | n/a | `any` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | n/a | `string` | `"azureadmin"` | no |
| <a name="input_fgt-active-ni_ids"></a> [fgt-active-ni\_ids](#input\_fgt-active-ni\_ids) | n/a | `map(string)` | `null` | no |
| <a name="input_fgt-passive-ni_ids"></a> [fgt-passive-ni\_ids](#input\_fgt-passive-ni\_ids) | n/a | `map(string)` | `null` | no |
| <a name="input_fgt_config_1"></a> [fgt\_config\_1](#input\_fgt\_config\_1) | n/a | `string` | `""` | no |
| <a name="input_fgt_config_2"></a> [fgt\_config\_2](#input\_fgt\_config\_2) | n/a | `string` | `""` | no |
| <a name="input_fgt_ha_fgsp"></a> [fgt\_ha\_fgsp](#input\_fgt\_ha\_fgsp) | n/a | `bool` | `false` | no |
| <a name="input_fgt_ni_0"></a> [fgt\_ni\_0](#input\_fgt\_ni\_0) | n/a | `string` | `"public"` | no |
| <a name="input_fgt_ni_1"></a> [fgt\_ni\_1](#input\_fgt\_ni\_1) | n/a | `string` | `"private"` | no |
| <a name="input_fgt_ni_2"></a> [fgt\_ni\_2](#input\_fgt\_ni\_2) | n/a | `string` | `"mgmt"` | no |
| <a name="input_fgt_offer"></a> [fgt\_offer](#input\_fgt\_offer) | n/a | `string` | `"fortinet_fortigate-vm_v5"` | no |
| <a name="input_fgt_passive"></a> [fgt\_passive](#input\_fgt\_passive) | n/a | `bool` | `false` | no |
| <a name="input_fgt_sku"></a> [fgt\_sku](#input\_fgt\_sku) | AMI | `map(string)` | <pre>{<br>  "byol": "fortinet_fg-vm",<br>  "payg": "fortinet_fg-vm_payg_2023"<br>}</pre> | no |
| <a name="input_fgt_version"></a> [fgt\_version](#input\_fgt\_version) | n/a | `string` | `"latest"` | no |
| <a name="input_license-active"></a> [license-active](#input\_license-active) | license file for the active fgt | `string` | `"/license-active.txt"` | no |
| <a name="input_license-passive"></a> [license-passive](#input\_license-passive) | license file for the passive fgt | `string` | `"/license-passive.txt"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License Type to create FortiGate-VM Provide the license type for FortiGate-VM Instances, either byol or payg. | `string` | `"payg"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"francecentral"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Azure resourcers prefix description | `string` | `"terraform"` | no |
| <a name="input_publisher"></a> [publisher](#input\_publisher) | n/a | `string` | `"fortinet"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `any` | n/a | yes |
| <a name="input_size"></a> [size](#input\_size) | For HA, choose instance size that support 4 nics at least Check : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes | `string` | `"Standard_F4"` | no |
| <a name="input_storage-account_endpoint"></a> [storage-account\_endpoint](#input\_storage-account\_endpoint) | n/a | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure resourcers tags | `map(any)` | <pre>{<br>  "Deploy": "module-fgt-ha",<br>  "Project": "terraform-fortinet"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | n/a |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | n/a |
| <a name="output_fgt-1_id"></a> [fgt-1\_id](#output\_fgt-1\_id) | n/a |
| <a name="output_fgt-2_id"></a> [fgt-2\_id](#output\_fgt-2\_id) | n/a |