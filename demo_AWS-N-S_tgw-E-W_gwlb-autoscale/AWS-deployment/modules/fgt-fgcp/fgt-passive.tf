##############################################################################################################
# FGT PASSIVE VM
##############################################################################################################

# Create and attach the eip to the units
resource "aws_eip" "eip-passive-mgmt" {
  vpc               = true
  network_interface = var.eni-passive["port1_id"]
  tags = {
    Name = "${var.prefix}-eip-passive-mgmt"
  }
}

# Create the instance FGT AZ2 Passive
resource "aws_instance" "passive-fgt" {
  ami                  = var.fgt-ami
  instance_type        = var.instance_type
  availability_zone    = var.region["region_az2"]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.APICall_profile.name
  user_data            = data.template_file.passive-fgt.rendered
  network_interface {
    device_index         = 0
    network_interface_id = var.eni-passive["port1_id"]
  }
  network_interface {
    device_index         = 1
    network_interface_id = var.eni-passive["port2_id"]
  }
  network_interface {
    device_index         = 2
    network_interface_id = var.eni-passive["port3_id"]
  }
  tags = {
    Name = "${var.prefix}-fgt-passive"
  }
}


data "template_file" "passive-fgt" {
  template = file("./templates/fgt.conf")

  vars = {
    fgt_id         = "${var.hub["id"]}-Passive"
    fgt_priority   = "100"
    admin-sport    = var.admin-sport
    admin_cidr     = var.admin_cidr
    type           = "${var.license_type}"
    license_file   = "${var.license}"
    rsa-public-key = var.rsa-public-key
    api_key        = var.api_key

    port1_ip   = var.eni-passive["port1_ip"]
    port1_mask = cidrnetmask(var.subnet-az2-vpc-sec["mgmt-ha_net"])
    port1_gw   = cidrhost(var.subnet-az2-vpc-sec["mgmt-ha_net"], 1)
    port2_ip   = var.eni-passive["port2_ip"]
    port2_mask = cidrnetmask(var.subnet-az2-vpc-sec["public_net"])
    port2_gw   = cidrhost(var.subnet-az2-vpc-sec["public_net"], 1)
    port3_ip   = var.eni-passive["port3_ip"]
    port3_mask = cidrnetmask(var.subnet-az2-vpc-sec["private_net"])
    port3_gw   = cidrhost(var.subnet-az2-vpc-sec["private_net"], 1)

    n-spoke-1-vm_net   = var.subnet-vpc-spoke["spoke-1-vm_net"]
    n-spoke-2-vm_net   = var.subnet-vpc-spoke["spoke-2-vm_net"]
    spokes-onprem-cidr = var.spokes-onprem-cidr

    peerip          = var.eni-active["port1_ip"]
    advpn-ipsec-psk = var.advpn-ipsec-psk

    sites_bgp-asn       = var.sites_bgp-asn
    hub_bgp-asn         = var.hub["bgp-asn"]
    hub_bgp-id          = var.hub["bgp-id"]
    hub_vxlan-ip1       = var.hub["vxlan-ip1"]
    hub_advpn-ip1       = var.hub["advpn-ip1"]
    hub-peer_bgp-asn    = var.hub-peer["bgp-asn"]
    hub-peer_public-ip1 = var.hub-peer["public-ip1"]
    hub-peer_vxlan-ip1  = var.hub-peer["vxlan-ip1"]
  }
}
