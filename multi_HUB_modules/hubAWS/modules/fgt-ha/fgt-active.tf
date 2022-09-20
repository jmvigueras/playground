##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################
# Create and attach the eip to the units
resource "aws_eip" "eip-cluster-public" {
  vpc               = true
  network_interface = var.eni-active["port2_id"]
  tags = {
    Name = "${var.prefix}-eip-cluster-public"
  }
}

resource "aws_eip" "eip-active-mgmt" {
  vpc               = true
  network_interface = var.eni-active["port1_id"]
  tags = {
    Name = "${var.prefix}-eip-active-mgmt"
  }
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length                 = 30
  special                = false
  numeric                = true
}

# Create the instance FGT AZ1 Active
resource "aws_instance" "active-fgt" {
  ami                  = var.license_type == "byol" ? var.fgtvmbyolami[var.region["region"]] : var.fgt-ond-amis[var.region["region"]]
  instance_type        = var.instance_type
  availability_zone    = var.region["region_az1"]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.APICall_profile.name
  user_data            = data.template_file.active-fgt.rendered
  network_interface {
    device_index         = 0
    network_interface_id = var.eni-active["port1_id"]
  }
  network_interface {
    device_index         = 1
    network_interface_id = var.eni-active["port2_id"]
  }
  network_interface {
    device_index         = 2
    network_interface_id = var.eni-active["port3_id"]
  }

  tags = {
    Name = "${var.prefix}-active-fgt"
  }
}

data "template_file" "active-fgt" {
  template = file("./templates/fgt.conf")

  vars = {
    fgt_id               = "${var.hub["id"]}-Active"
    fgt_priority         = "200"
    api_key              = random_string.api_key.result
    admin_port           = var.admin_port
    admin_cidr           = var.admin_cidr
    type                 = "${var.license_type}"
    license_file         = "${var.license}"

    port1_ip             = var.eni-active["port1_ip"]
    port1_mask           = cidrnetmask(var.subnet-az1-vpc-sec["mgmt-ha_net"])
    port1_gw             = cidrhost(var.subnet-az1-vpc-sec["mgmt-ha_net"], 1)
    port2_ip             = var.eni-active["port2_ip"]
    port2_mask           = cidrnetmask(var.subnet-az1-vpc-sec["public_net"])
    port2_gw             = cidrhost(var.subnet-az1-vpc-sec["public_net"], 1)
    port3_ip             = var.eni-active["port3_ip"]
    port3_mask           = cidrnetmask(var.subnet-az1-vpc-sec["private_net"])
    port3_gw             = cidrhost(var.subnet-az1-vpc-sec["private_net"], 1)

    spoke-1-vm_net       = var.subnet-vpc-spoke["spoke-1-vm_net"]
    spoke-2-vm_net       = var.subnet-vpc-spoke["spoke-2-vm_net"]
    spokes-onprem-cidr   = var.spokes-onprem-cidr

    peerip               = var.eni-passive["port1_ip"]
    advpn-ipsec-psk      = var.advpn-ipsec-psk

    sites_bgp-asn           = var.sites_bgp-asn
    hub_bgp-asn             = var.hub["bgp-asn"]
    hub_bgp-id              = var.hub["bgp-id"]
    hub_vxlan-ip1           = var.hub["vxlan-ip1"]
    hub_advpn-ip1           = cidrhost(var.hub["advpn-net"],1)
    hub_advpn-ip2           = cidrhost(var.hub["advpn-net"],2)
    hub_advpn-net           = var.hub["advpn-net"]
    hub-peer_bgp-asn        = var.hub-peer["bgp-asn"]
    hub-peer_public-ip1     = var.hub-peer["public-ip1"]
    hub-peer_vxlan-ip1      = var.hub-peer["vxlan-ip1"]
  }
}
