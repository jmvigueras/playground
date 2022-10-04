# Deployment of FortiGate-VM HA on the Google Cloud Platform (GCP)
## Introduction
A Terraform script to deploy FortiGate-VM HA (A-P) on GCP multi Virtual Private Cloud (VPC)

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 0.12.0
* Terraform Provider for Google Cloud Platform >=2.11.0
* Terraform Provider for Google Cloud Platform Beta >=2.13
* Terraform Provider for random 2.2.1
* Terraform Provider for template 2.1.2
* A [GCP OAuth2 access token](https://developers.google.com/identity/protocols/OAuth2)

## Deployment overview
Terraform deploys the following components:
   - A VPC with one public subnet - port1 FTG
   - A VPC INTERNAL - port2 FTG
   - A VPC SPOKE1 - port4 FTG
   - A VPC SPOKE2 - port5 FTG
   - A VPC MGMT and HA - port 3 FTG for management and ha
   - Two FortiGate-VM (BYOL/PAYG) instances with five NICs
   - Firewall rules for allowing traffic to public interface from internal, spoke1 and spoke2, also between spokes.

## Diagram solution

![FortiGate reference architecture overview](images/Schema-FGT-HA-multi-vpc.png)

## HA failover
SDN connector for GCP is used to update subnets routes and cluster IP.
   - Subnet private-route is update to fortigate IP on that interface
   - Subnet spoke1-route is update to fortigate IP on that interface
   - Subnet spoke2-route is update to fortigate IP on that interface
   - External IP cluster-ip is linked to public interface

## Deployment
To deploy the FortiGate-VM to GCP:
1. Clone the repository.
2. Obtain a GCP OAuth2 token and input it in the vars.tf file.
3. Customize variables in the `vars.tf` file as needed.
4. Initialize the providers and modules:
   ```sh
   $ cd XXXXX
   $ terraform init
    ```
5. Submit the Terraform plan:
   ```sh
   $ terraform plan
   ```
6. Verify output.
7. Confirm and apply the plan:
   ```sh
   $ terraform apply
   ```
8. If output is satisfactory, type `yes`.

Output will include the information necessary to log in to the FortiGate-VM instances:
```sh
FortiGate-HA-Cluster-IP = XXX.XXX.XXX.XXX
FortiGate-HA-Master-MGMT-IP = XXX.XXX.XXX.XXX
FortiGate-HA-Slave-MGMT-IP = XXX.XXX.XXX.XXX
FortiGate-Password = <password here>
FortiGate-Username = admin
```

## Destroy the instance
To destroy the instance, use the command:
```sh
$ terraform destroy
```

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, soy take it in count before proceed.

## License
Based on Fortinet repositories with original [License](https://github.com/fortinet/fortigate-terraform-deploy/blob/master/LICENSE) © Fortinet Technologies. All rights reserved.