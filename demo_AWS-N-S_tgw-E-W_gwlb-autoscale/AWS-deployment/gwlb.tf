#---------------------------------------------------------------------------
# GWLB
# - Target group FGT-active and passive
#---------------------------------------------------------------------------
// Create Gateway LB
resource "aws_lb" "gwlb" {
  load_balancer_type               = "gateway"
  name                             = "${var.prefix}-gwlb"
  enable_cross_zone_load_balancing = false
  subnets = [
    module.vpc-sec-fgsp.subnet-az1_ids["gwlb"],
    module.vpc-sec-fgsp.subnet-az2_ids["gwlb"]
  ]
}
// Create GWLB Service
resource "aws_vpc_endpoint_service" "gwlb_service" {
  acceptance_required        = false
  allowed_principals         = [data.aws_caller_identity.current.arn]
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]
}
// Create Gateway LB target group GENEVE
resource "aws_lb_target_group" "gwlb_target-group" {
  name     = "${var.prefix}-gwlb-target-group"
  port     = 6081
  protocol = "GENEVE"
  vpc_id   = module.vpc-sec-fgsp.vpc["id"]

  health_check {
    port     = var.backend-probe_port
    protocol = "HTTP"
    interval = 10
  }
}
// Create Gateway LB Listener
resource "aws_lb_listener" "gwlb_listener" {
  load_balancer_arn = aws_lb.gwlb.id

  default_action {
    target_group_arn = aws_lb_target_group.gwlb_target-group.id
    type             = "forward"
  }
}
// Create GWLB target group attachemnt to FGT master
resource "aws_lb_target_group_attachment" "gwlb_target-group_attch-1" {
  target_group_arn = aws_lb_target_group.gwlb_target-group.arn
  target_id        = module.fgt-fgsp.id
}

// ELB attachments
resource "aws_autoscaling_attachment" "gwlb_attch_asg-az1" {
  autoscaling_group_name = aws_autoscaling_group.fgt_az1_asg-payg.id
  lb_target_group_arn    = aws_lb_target_group.gwlb_target-group.arn
}
resource "aws_autoscaling_attachment" "gwlb_attch_asg-az2" {
  autoscaling_group_name = aws_autoscaling_group.fgt_az2_asg-payg.id
  lb_target_group_arn    = aws_lb_target_group.gwlb_target-group.arn
}

// Principal ARN to discover GWLB Service
data "aws_caller_identity" "current" {}

// Get GWLB interfaces
data "aws_network_interfaces" "gwlb_raw-ni-az1" {
  filter {
    name   = "description"
    values = ["ELB gwy/${aws_lb.gwlb.name}/*"]
  }
  filter {
    name   = "subnet-id"
    values = ["${module.vpc-sec-fgsp.subnet-az1_ids["gwlb"]}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "attachment.status"
    values = ["attached"]
  }
}

// Create GWLB NI resource with NI IDs
data "aws_network_interface" "gwlb_ni-az1" {
  filter {
    name   = "description"
    values = ["ELB gwy/${aws_lb.gwlb.name}/*"]
  }
  filter {
    name   = "subnet-id"
    values = ["${module.vpc-sec-fgsp.subnet-az1_ids["gwlb"]}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "attachment.status"
    values = ["attached"]
  }
}

data "aws_network_interface" "gwlb_ni-az2" {
  filter {
    name   = "description"
    values = ["ELB gwy/${aws_lb.gwlb.name}/*"]
  }
  filter {
    name   = "subnet-id"
    values = ["${module.vpc-sec-fgsp.subnet-az2_ids["gwlb"]}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "attachment.status"
    values = ["attached"]
  }
}


