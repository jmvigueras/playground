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

// Creat public IP for instance
resource "aws_eip" "eip-vpc-spoke-1-vm" {
  vpc               = true
  network_interface = module.vpc-spoke.ni-spoke-vm_id["spoke-1_id"]
  tags = {
    Name    = "${var.prefix}-eip-vpc-spoke-1-vm"
    Project = var.tag-project
  }
}

# test device in spoke1
resource "aws_instance" "instance-spoke-1" {
  depends_on    = [module.vpc-spoke]
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.keypair != null ? var.keypair : aws_key_pair.keypair[0].key_name

  network_interface {
    device_index         = 0
    network_interface_id = module.vpc-spoke.ni-spoke-vm_id["spoke-1_id"]
  }

  tags = {
    Name    = "${var.prefix}-vm-spoke1"
    Project = var.tag-project
  }
}

// Creat public IP for instance
resource "aws_eip" "eip-vpc-spoke-2-vm" {
  vpc               = true
  network_interface = module.vpc-spoke.ni-spoke-vm_id["spoke-2_id"]
  tags = {
    Name    = "${var.prefix}-eip-vpc-spoke-2-vm"
    Project = var.tag-project
  }
}

# test device in spoke2
resource "aws_instance" "instance-spoke-2" {
  depends_on    = [module.vpc-spoke]
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.keypair != null ? var.keypair : aws_key_pair.keypair[0].key_name

  network_interface {
    device_index         = 0
    network_interface_id = module.vpc-spoke.ni-spoke-vm_id["spoke-2_id"]
  }

  tags = {
    Name    = "${var.prefix}-vm-spoke2"
    Project = var.tag-project
  }
}


