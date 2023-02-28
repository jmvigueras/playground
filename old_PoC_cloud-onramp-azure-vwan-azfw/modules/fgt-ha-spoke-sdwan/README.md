# Deployment Fortigate site spoke on the Azure with Terraform
## Introduction

This terraform code will deploy a fortigate site, simulating and on premise site connected to HUB over different WAN connections.

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 0.12.0
* Terraform Provider AzureRM >= 2.24.0
* Terraform Provider Template >= 2.2.0
* Terraform Provider Random >= 3.1.0


## Deployment overview
It is highly recomended to used other modules as inputs to generate necessary variables for this module. Check example to see how to use modules `vnet-fgt` and `vm`.
   - module vnet-fgt (`github.com/jmvigueras/modules/azure/vnet-fgt`)
   - module vm (`github.com/jmvigueras/modules/azure/vm`)

Needed to update vars_hubs.tf
   - Complete data of each HUB to connect with SDWAN Fortinet as list of collections as it is showed here:

   ```sh
      variable "hubs" {
      type = list(map(string))
      default = [
         {
            id         = "HUB1"           // id (will be used as zone Id)
            bgp-asn    = "65001"          // hub bgp ASN
            public-ip  = "11.11.11.11"    // public IP to connect 
            hub-ip     = "172.20.30.1"    // hub IP in IPSEC tunnel
            site-ip    = "172.20.30.12"   // sit IP in IPSEC tunnel
            hck-srv-ip = "172.20.30.1"    // IP server to check health check
            advpn-psk  = "secret"         // IPSEC PSK
            cidr       = "172.20.30.0/24" // Net range of HUB 
         },
         {
            id         = "HUB1"
            bgp-asn    = "65001"
            public-ip  = "11.11.11.12"
            hub-ip     = "172.25.30.1"
            site-ip    = "172.25.30.12"
            hck-srv-ip = "172.25.30.1"
            advpn-psk  = "secret"
            cidr       = "172.25.30.0/24"
         },
         {
            id         = "HUB2"
            bgp-asn    = "65002"
            public-ip  = "22.22.22.22"
            hub-ip     = "172.25.30.1"
            site-ip    = "172.25.30.12"
            hck-srv-ip = "172.25.30.1"
            advpn-psk  = "secret"
            cidr       = "172.25.30.0/24"
         }
      ]
      }
   ```
      - Update site details:
   ```sh
      variable "site" {
      type = map(any)
      default = {
         id      = "site-1"           // site id
         cidr    = "192.168.0.0/20"   // site cidr range
         bgp-asn = "65011"            // bgp asn for site (same as hub for iBGP)
         ha      = true               // (true|false), true for fortigate in HA deployment 
      }
      }
   ```
## Deployment diagram

![diagram deployment](images/image1.png)


## Deployment considerations:
   - Create file terraform.tfvars using terraform.tfvars.example as template 
   - Update variables in var.tf with fortigate cluster deployment
   - You will be charged for this deployment

## Deployment
To deploy the FortiGate-VM to Azure:
1. Create module with source `source = "github.com/jmvigueras/modules/azure/vnet-spoke`
2. Customize variables in the `terraform.tfvars.example` and `vars.tf` file as needed.  And rename `terraform.tfvars.example` to `terraform.tfvars`.
3. Initialize the providers and modules:
   ```sh
   $ cd XXXXX
   $ terraform init
    ```
4. Submit the Terraform plan:
   ```sh
   $ terraform plan
   ```
5. Verify output.
6. Confirm and apply the plan:
   ```sh
   $ terraform apply
   ```
7. If output is satisfactory, type `yes`.

Output will include the information necessary:
```sh
Outputs:

<Detail info of VNETs and Subnet deployed>
```

## Destroy the deployment
To destroy the instance, use the command:
```sh
$ terraform destroy
```

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.

## License
Based on Fortinet repositories with original [License](https://github.com/fortinet/fortigate-terraform-deploy/blob/master/LICENSE) © Fortinet Technologies. All rights reserved.

