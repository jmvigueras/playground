##############################################################################################################
# TRANSIT GATEWAY
##############################################################################################################
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway with 4 VPC"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name    = "${var.prefix}-tgw"
    Project = var.tag-project
  }
}

# Route Tables
resource "aws_ec2_transit_gateway_route_table" "rt-vpc-spokes" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name    = "${var.prefix}-rt-vpc-spokes"
    Project = var.tag-project
  }
}
resource "aws_ec2_transit_gateway_route_table" "rt-vpc-sec-fgcp" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name    = "${var.prefix}-rt-vpc-sec-fgcp"
    Project = var.tag-project
  }
}
resource "aws_ec2_transit_gateway_route_table" "rt-vpc-sec-fgsp" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name    = "${var.prefix}-rt-vpc-sec-fgsp"
    Project = var.tag-project
  }
}

# TGW routes

// Routes table route FGCP
// - Spokes ranges to spoke attachment
resource "aws_ec2_transit_gateway_route" "r-fgcp-cidr-vpc-spoke-1" {
  destination_cidr_block         = module.vpc-spoke.subnet-spoke-vm["spoke-1-vm_net"]
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec-fgcp.id
}
resource "aws_ec2_transit_gateway_route" "r-fgcp-cidr-vpc-spoke-2" {
  destination_cidr_block         = module.vpc-spoke.subnet-spoke-vm["spoke-2-vm_net"]
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-2_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec-fgcp.id
}

// Routes table route FGSP
// - Default to FGCP
// - Spokes ranges to spoke attachment
resource "aws_ec2_transit_gateway_route" "r-fgsp-default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc-sec-fgcp.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec-fgsp.id
}
resource "aws_ec2_transit_gateway_route" "r-fgsp-cidr-vpc-spoke-1" {
  destination_cidr_block         = module.vpc-spoke.subnet-spoke-vm["spoke-1-vm_net"]
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec-fgsp.id
}
resource "aws_ec2_transit_gateway_route" "r-fgsp-cidr-vpc-spoke-2" {
  destination_cidr_block         = module.vpc-spoke.subnet-spoke-vm["spoke-2-vm_net"]
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-2_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec-fgsp.id
}

// Routes table route Spokes
// - (N-S) Default to FGCP attachment
// - (E-W) Spokes ranges to FGSP attachment
resource "aws_ec2_transit_gateway_route" "r-spokes-default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc-sec-fgcp.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}
resource "aws_ec2_transit_gateway_route" "r-spokes-cidr-vpc-spoke-1" {
  destination_cidr_block         = module.vpc-spoke.subnet-spoke-vm["spoke-1-vm_net"]
  transit_gateway_attachment_id  = module.vpc-sec-fgsp.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}
resource "aws_ec2_transit_gateway_route" "r-spokes-cidr-vpc-spoke-2" {
  destination_cidr_block         = module.vpc-spoke.subnet-spoke-vm["spoke-2-vm_net"]
  transit_gateway_attachment_id  = module.vpc-sec-fgsp.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}

# Route Tables Associations
// - Spokes
// - FGCP
// - FGSP
resource "aws_ec2_transit_gateway_route_table_association" "ra-vpc-spoke-1" {
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}
resource "aws_ec2_transit_gateway_route_table_association" "ra-vpc-spoke-2" {
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-2_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}
resource "aws_ec2_transit_gateway_route_table_association" "ra-vpc-sec-fgcp" {
  transit_gateway_attachment_id  = module.vpc-sec-fgcp.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec-fgcp.id
}
resource "aws_ec2_transit_gateway_route_table_association" "ra-vpc-sec-fgsp" {
  transit_gateway_attachment_id  = module.vpc-sec-fgsp.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec-fgsp.id
}