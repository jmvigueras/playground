// Create VPC-SEC
module "vpc-sec-fgsp" {
  source = "./modules/vpc-sec-fgsp"

  prefix      = "${var.prefix}-fgsp"
  admin_cidr  = var.admin_cidr
  admin-sport = var.admin-sport
  region      = var.region

  vpc-sec_net = "172.30.0.0/20"

  tgw_id            = aws_ec2_transit_gateway.tgw.id
  gwlb_service-name = aws_vpc_endpoint_service.gwlb_service.service_name
}

// Create master FGT
module "fgt-fgsp" {
  depends_on = [module.vpc-sec-fgsp, aws_lb.gwlb]
  source     = "./modules/fgt-fgsp"

  fgt-ami = data.aws_ami_ids.fgt-ond-amis.ids[0]
  prefix  = "${var.prefix}-fgsp"

  admin-sport    = var.admin-sport
  region         = var.region
  keypair        = var.keypair != null ? var.keypair : aws_key_pair.keypair[0].key_name
  instance_type  = var.instance_type
  rsa-public-key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  eni = module.vpc-sec-fgsp.fgt_eni

  gwlb_ip1 = data.aws_network_interface.gwlb_ni-az1.private_ip
  gwlb_ip2 = data.aws_network_interface.gwlb_ni-az2.private_ip

  subnet-az1-vpc-sec = module.vpc-sec-fgsp.subnet-az1_cidr
  subnet-az2-vpc-sec = module.vpc-sec-fgsp.subnet-az2_cidr

  backend-probe_port = var.backend-probe_port
}

// Create launch templates AZ1
resource "aws_launch_template" "fgt_az1_launchtemplate" {
  name_prefix   = "${var.prefix}-fgt-az1-lp-payg"
  image_id      = data.aws_ami_ids.fgt-ond-amis.ids[0]
  instance_type = var.instance_type
  user_data     = base64encode(data.template_file.fgt-asg.rendered)

  network_interfaces {
    device_index          = 0
    delete_on_termination = true
    subnet_id             = module.vpc-sec-fgsp.subnet-az1_ids["private"]
    security_groups       = [module.vpc-sec-fgsp.nsg_ids["private"]]
  }
}
// Create launch templates AZ2
resource "aws_launch_template" "fgt_az2_launchtemplate" {
  name_prefix   = "${var.prefix}-fgt-az2-lp-payg"
  image_id      = data.aws_ami_ids.fgt-ond-amis.ids[0]
  instance_type = var.instance_type
  user_data     = base64encode(data.template_file.fgt-asg.rendered)

  network_interfaces {
    device_index          = 0
    delete_on_termination = true
    subnet_id             = module.vpc-sec-fgsp.subnet-az2_ids["private"]
    security_groups       = [module.vpc-sec-fgsp.nsg_ids["private"]]
  }
}

// Create ASG AZ1
resource "aws_autoscaling_group" "fgt_az1_asg-payg" {
  name                = "${var.prefix}-fgt-az1-asg-payg"
  desired_capacity    = 0
  max_size            = 1
  min_size            = 0
  vpc_zone_identifier = [module.vpc-sec-fgsp.subnet-az1_ids["private"]]

  launch_template {
    id      = aws_launch_template.fgt_az1_launchtemplate.id
    version = "$Latest"
  }
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

// Create ASG AZ2
resource "aws_autoscaling_group" "fgt_az2_asg-payg" {
  name                = "${var.prefix}-fgt-az2-asg-payg"
  desired_capacity    = 0
  max_size            = 1
  min_size            = 0
  vpc_zone_identifier = [module.vpc-sec-fgsp.subnet-az2_ids["private"]]

  launch_template {
    id      = aws_launch_template.fgt_az2_launchtemplate.id
    version = "$Latest"
  }
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

// Data template
data "template_file" "fgt-asg" {
  template = file("./templates/fgt-fgsp-asg.conf")
  vars = {
    gwlb_ip1           = data.aws_network_interface.gwlb_ni-az1.private_ip
    gwlb_ip2           = data.aws_network_interface.gwlb_ni-az2.private_ip
    fgt_master_ip      = module.vpc-sec-fgsp.fgt_eni["port2_ip"]
    admin-sport        = var.admin-sport
    rsa-public-key     = tls_private_key.ssh.public_key_openssh
    ip_primary         = module.vpc-sec-fgsp.fgt_eni["port1_ip"]
    backend-probe_port = var.backend-probe_port
    subnet-az1-gwlb    = module.vpc-sec-fgsp.subnet-az1_cidr["gwlb"]
    subnet-az2-gwlb    = module.vpc-sec-fgsp.subnet-az2_cidr["gwlb"]
    api_key            = random_string.api_key.result
  }
}



