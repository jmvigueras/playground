// Create VPC-SEC
module "vpc-sec-fgcp" {
  source = "./modules/vpc-sec-fgcp"

  prefix      = "${var.prefix}-fgcp"
  admin_cidr  = var.admin_cidr
  admin-sport = var.admin-sport
  region      = var.region
  tags        = var.tags

  vpc-sec_net = "172.31.0.0/20"

  tgw_id            = aws_ec2_transit_gateway.tgw.id
  gwlb_service-name = aws_vpc_endpoint_service.gwlb_service.service_name
}

// Create Active FGT
module "fgt-ha" {
  depends_on = [module.vpc-sec-fgcp]
  source     = "./modules/fgt-fgcp"

  fgt-ami        = data.aws_ami_ids.fgt-ond-amis.ids[0]
  prefix         = "${var.prefix}-fgcp"
  admin_cidr     = "${chomp(data.http.my-public-ip.response_body)}/32"
  admin-sport    = var.admin-sport
  region         = var.region
  keypair        = var.keypair != null ? var.keypair : aws_key_pair.keypair[0].key_name
  tags           = var.tags
  instance_type  = var.instance_type
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = random_string.api_key.result

  vpc-sec_net = "172.31.0.0/20"

  eni-active  = module.vpc-sec-fgcp.eni-active
  eni-passive = module.vpc-sec-fgcp.eni-passive

  subnet-az1-vpc-sec = module.vpc-sec-fgcp.subnet-az1-vpc-sec
  subnet-az2-vpc-sec = module.vpc-sec-fgcp.subnet-az2-vpc-sec

  subnet-vpc-spoke = module.vpc-spoke.subnet-spoke-vm

  hub           = var.hub
  hub-peer      = var.hub-peer
  sites_bgp-asn = var.sites_bgp-asn

  advpn-ipsec-psk = var.advpn-ipsec-psk
}