# Create and attach the eip to the units
resource "aws_eip" "fgt_active_eip_public" {
  vpc               = true
  network_interface = var.fgt-active-ni_ids["public"]
  tags = {
    Name = "${var.prefix}-fgt_active_eip_public"
  }
}
/*
resource "aws_eip" "fgt_active_eip_mgmt" {
  vpc               = true
  network_interface = var.fgt-active-ni_ids["mgmt"]
  tags = {
    Name = "${var.prefix}-fgt_active_eip_mgmt"
  }
}

# Create and attach the eip to the units
resource "aws_eip" "fgt_passive_eip_mgmt" {
  vpc               = true
  network_interface = var.fgt-passive-ni_ids["mgmt"]
  tags = {
    Name = "${var.prefix}-fgt_passive_eip_mgmt"
  }
}
*/

# Create and attach the eip to the units
resource "aws_eip" "fgt_passive_eip_public" {
  count             = var.fgt-passive-ni_ids != null && var.fgt_passive && var.fgt_ha_fgsp ? 1 : 0
  vpc               = true
  network_interface = var.fgt-passive-ni_ids["public"]
  tags = {
    Name = "${var.prefix}-fgt_passive_eip_public"
  }
}

# Create the instance FGT AZ1 Active
resource "aws_instance" "fgt_active" {
  ami                  = var.license_type == "byol" ? data.aws_ami_ids.fgt_amis_byol.ids[0] : data.aws_ami_ids.fgt_amis_payg.ids[0]
  instance_type        = var.instance_type
  availability_zone    = var.region["az1"]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.APICall_profile.name
  user_data            = var.fgt_config_1
  network_interface {
    device_index         = 0
    network_interface_id = var.fgt-active-ni_ids[var.fgt_ni_0]
  }
  network_interface {
    device_index         = 1
    network_interface_id = var.fgt-active-ni_ids[var.fgt_ni_1]
  }
  network_interface {
    device_index         = 2
    network_interface_id = var.fgt-active-ni_ids[var.fgt_ni_2]
  }
  tags = {
    Name = var.fgt_ha_fgsp ? "${var.prefix}-fgt-1" : "${var.prefix}-fgt-active"
  }
}

# Create the instance FGT AZ2 Passive
resource "aws_instance" "fgt_passive" {
  count                = var.fgt-passive-ni_ids != null && var.fgt_passive ? 1 : 0
  ami                  = var.license_type == "byol" ? data.aws_ami_ids.fgt_amis_byol.ids[0] : data.aws_ami_ids.fgt_amis_payg.ids[0]
  instance_type        = var.instance_type
  availability_zone    = var.region["az2"]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.APICall_profile.name
  user_data            = var.fgt_config_2
  network_interface {
    device_index         = 0
    network_interface_id = var.fgt-passive-ni_ids[var.fgt_ni_0]
  }
  network_interface {
    device_index         = 1
    network_interface_id = var.fgt-passive-ni_ids[var.fgt_ni_1]
  }
  network_interface {
    device_index         = 2
    network_interface_id = var.fgt-passive-ni_ids[var.fgt_ni_2]
  }
  tags = {
    Name = var.fgt_ha_fgsp ? "${var.prefix}-fgt-2" : "${var.prefix}-fgt-passive"
  }
}


# Get the last AMI Images from AWS MarektPlace FGT PAYG
data "aws_ami_ids" "fgt_amis_payg" {
  owners = ["679593333241"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWSONDEMAND ${var.fgt_build}*"]
  }
}

# Get the last AMI Images from AWS MarektPlace FGT BYOL
data "aws_ami_ids" "fgt_amis_byol" {
  owners = ["679593333241"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWS ${var.fgt_build}*"]
  }
}