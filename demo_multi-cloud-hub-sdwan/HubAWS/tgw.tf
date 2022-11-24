##############################################################################################################
# TRANSIT GATEWAY
##############################################################################################################
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway with 3 VPC"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "${var.prefix}-tgw"
  }
}

# Route Tables
resource "aws_ec2_transit_gateway_route_table" "rt-vpc-spokes" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.prefix}-rt-vpc-spokes"
  }
}

resource "aws_ec2_transit_gateway_route_table" "rt-vpc-sec" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.prefix}-rt-vpc-sec"
  }
}

# TGW routes
resource "aws_ec2_transit_gateway_route" "r-cidr-vpc-spoke-1" {
  destination_cidr_block         = module.vpc-spoke.subnet-vpc-spoke["spoke-1-vm_net"]
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec.id
}

resource "aws_ec2_transit_gateway_route" "r-cidr-vpc-spoke-2" {
  destination_cidr_block         = module.vpc-spoke.subnet-vpc-spoke["spoke-2-vm_net"]
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-2_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec.id
}

resource "aws_ec2_transit_gateway_route" "r-default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc-sec.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}


# Route Tables Associations
resource "aws_ec2_transit_gateway_route_table_association" "ra-vpc-spoke-1" {
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}

resource "aws_ec2_transit_gateway_route_table_association" "ra-vpc-spoke-2" {
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-2_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}

resource "aws_ec2_transit_gateway_route_table_association" "ra-vpc-sec" {
  transit_gateway_attachment_id  = module.vpc-sec.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec.id
}



// Route propagation (as we want all traffic goes through FW there will be no propagation)

/*
# Route Tables Propagations
## This section defines which VPCs will be routed from each Route Table created in the Transit Gateway
resource "aws_ec2_transit_gateway_route_table_propagation" "rp-vpc-spoke-1" {
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prp-vpc2" {
  transit_gateway_attachment_id  = module.vpc-spoke.tgw-att-vpc-spoke-2_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-spokes.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prp-mgmt-tovpc1" {
  transit_gateway_attachment_id  = module.vpc-sec.tgw-att-vpc-sec_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-vpc-sec.id
}
*/