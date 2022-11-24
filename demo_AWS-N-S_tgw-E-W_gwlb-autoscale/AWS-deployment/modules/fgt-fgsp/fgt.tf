##############################################################################################################
# FORTIGATES VM
##############################################################################################################

// Creat public IP for master member
resource "aws_eip" "fgt_eip-port2" {
  vpc               = true
  network_interface = var.eni["port2_id"]
  tags = {
    Name = "${var.prefix}-eip-master-mgmt"
  }
}

# Create the instance FGT AZ1 Active
resource "aws_instance" "fgt" {
  ami                  = var.fgt-ami
  instance_type        = var.instance_type
  availability_zone    = var.region["region_az1"]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.APICall_profile.name
  user_data            = data.template_file.fgt-master.rendered
  network_interface {
    device_index         = 0
    network_interface_id = var.eni["port1_id"]
  }
  network_interface {
    device_index         = 1
    network_interface_id = var.eni["port2_id"]
  }
  tags = {
    Name = "${var.prefix}-fgt-master"
  }
}

data "template_file" "fgt-master" {
  template = file("./templates/fgt-fgsp-master.conf")

  vars = {
    fgt_id         = "${var.prefix}-fgt-master"
    admin-sport    = var.admin-sport
    admin_cidr     = var.admin_cidr
    rsa-public-key = var.rsa-public-key
    api_key        = var.api_key

    port1_ip   = var.eni["port1_ip"]
    port1_mask = cidrnetmask(var.subnet-az1-vpc-sec["private"])
    port1_gw   = cidrhost(var.subnet-az1-vpc-sec["private"], 1)
    port2_ip   = var.eni["port2_ip"]
    port2_mask = cidrnetmask(var.subnet-az1-vpc-sec["mgmt"])
    port2_gw   = cidrhost(var.subnet-az1-vpc-sec["mgmt"], 1)

    gwlb_ip1 = var.gwlb_ip1
    gwlb_ip2 = var.gwlb_ip2

    backend-probe_port = var.backend-probe_port

    subnet-az1-gwlb = var.subnet-az1-vpc-sec["gwlb"]
    subnet-az2-gwlb = var.subnet-az2-vpc-sec["gwlb"]
  }
}

