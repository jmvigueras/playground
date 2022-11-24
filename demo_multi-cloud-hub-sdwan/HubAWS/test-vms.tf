##############################################################################################################
# VM LINUX for testing
##############################################################################################################

## Retrieve AMI info
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# test device in spoke1
resource "aws_instance" "instance-spoke-1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.keypair
  network_interface {
    device_index         = 0
    network_interface_id = module.vpc-spoke.ni-vm-spoke_ids["spoke-1-vm"]
  }

  tags = {
    Name = "${var.prefix}-vm-spoke1"
  }
}

# test device in spoke2
resource "aws_instance" "instance-spoke-2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.keypair
  network_interface {
    device_index         = 0
    network_interface_id = module.vpc-spoke.ni-vm-spoke_ids["spoke-2-vm"]
  }

  tags = {
    Name = "${var.prefix}-vm-spoke2"
  }
}


