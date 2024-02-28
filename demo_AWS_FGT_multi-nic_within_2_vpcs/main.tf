#-----------------------------------------------------------------------------------------------------
# Create VPC 1 and FGT cluster
#-----------------------------------------------------------------------------------------------------
# Create VPC 1
module "fgt_vpc_1" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.5"

  prefix     = "${local.prefix}-vpc-1"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.fgt_vpc_1_cidr

  public_subnet_names  = local.vpc_1_public_subnet_names
  private_subnet_names = local.vpc_1_private_subnet_names
}
# Create FGT NIs
module "fgt_nis" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_ni_sg"
  version = "0.0.5"

  prefix = "${local.prefix}-vpc-1"
  azs    = local.azs

  vpc_id      = module.fgt_vpc_1.vpc_id
  subnet_list = module.fgt_vpc_1.subnet_list

  fgt_subnet_tags = local.fgt_subnet_tags

  fgt_number_peer_az = local.fgt_number_peer_az
  cluster_type       = local.fgt_cluster_type
}
# Create FGTs config
module "fgt_config" {
  for_each = { for k, v in module.fgt_nis.fgt_ports_config : k => v }

  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_config"
  version = "0.0.5"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  ports_config = each.value

  config_fgcp       = local.fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.fgt_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.fgt_nis.fgt_ports_config

  static_route_cidrs = [local.fgt_vpc_1_cidr, local.fgt_vpc_2_cidr] //necessary routes to stablish BGP peerings and bastion connection
}
# Create FGT instances
module "fgt" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt"
  version = "0.0.5"

  prefix        = local.prefix
  region        = local.region
  instance_type = local.instance_type
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.fgt_nis.fgt_ni_list
  fgt_config  = { for k, v in module.fgt_config : k => v.fgt_config }
}
# Crate test VM in bastion subnet
module "vpc_1_vm" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vm"
  version = "0.0.5"

  prefix          = "${local.prefix}-vpc-1"
  keypair         = aws_key_pair.keypair.key_name
  subnet_id       = module.fgt_vpc_1.subnet_ids["az1"]["bastion"]
  subnet_cidr     = module.fgt_vpc_1.subnet_cidrs["az1"]["bastion"]
  security_groups = [module.fgt_vpc_1.sg_ids["default"]]
}
# Update private RT route RFC1918 cidrs to FGT NI
module "vpc_1_routes" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.5"

  ni_id     = module.fgt_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = { "bastion-az1" = module.fgt_vpc_1.rt_public_ids["bastion-az1"] }
}
#-----------------------------------------------------------------------------------------------------
# Create VPC 2, ENI and VM test
#-----------------------------------------------------------------------------------------------------
# Create VPC for hub EU
module "fgt_vpc_2" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.5"

  prefix     = "${local.prefix}-vpc-2"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.fgt_vpc_2_cidr

  public_subnet_names  = local.vpc_2_public_subnet_names
  private_subnet_names = local.vpc_2_private_subnet_names
}
# Crate test VM in bastion subnet
module "vpc_2_vm" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vm"
  version = "0.0.5"

  prefix          = "${local.prefix}-vpc-2"
  keypair         = aws_key_pair.keypair.key_name
  subnet_id       = module.fgt_vpc_2.subnet_ids["az1"]["bastion"]
  subnet_cidr     = module.fgt_vpc_2.subnet_cidrs["az1"]["bastion"]
  security_groups = [module.fgt_vpc_2.sg_ids["default"]]
}
# Create ENI FGT 1 VPC2
resource "aws_network_interface" "fgt_1_eni_vpc_2" {
  subnet_id       = module.fgt_vpc_2.subnet_ids["az1"]["private"]
  security_groups = [module.fgt_vpc_2.sg_ids["default"]]
  private_ip_list = [cidrhost(module.fgt_vpc_2.subnet_cidrs["az1"]["private"], 9), cidrhost(module.fgt_vpc_2.subnet_cidrs["az1"]["private"], 10)]

  source_dest_check       = false
  private_ip_list_enabled = true

  tags = { Name = "${local.prefix}-vpc-2-az1.fgt1.port4.private-ni" }
}
# Attach ENI to FGT1
resource "aws_network_interface_attachment" "fgt_1_eni_vpc_2_attach" {
  instance_id          = module.fgt.fgt_peer_az_ids["az1.fgt1"]
  network_interface_id = aws_network_interface.fgt_1_eni_vpc_2.id
  device_index         = 3
}
# Create ENI FGT 2 VPC2
resource "aws_network_interface" "fgt_2_eni_vpc_2" {
  subnet_id       = module.fgt_vpc_2.subnet_ids["az1"]["private"]
  security_groups = [module.fgt_vpc_2.sg_ids["default"]]
  private_ip_list = [cidrhost(module.fgt_vpc_2.subnet_cidrs["az1"]["private"], 11)]

  source_dest_check       = false
  private_ip_list_enabled = true

  tags = { Name = "${local.prefix}-vpc-2-az1.fgt2.port4.private-ni" }
}
# Attach ENI to FGT2
resource "aws_network_interface_attachment" "fgt_2_eni_vpc_2_attach" {
  instance_id          = module.fgt.fgt_peer_az_ids["az1.fgt2"]
  network_interface_id = aws_network_interface.fgt_2_eni_vpc_2.id
  device_index         = 3
}
# Update private RT route RFC1918 cidrs to FGT NI
module "vpc_2_routes" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.5"

  ni_id     = aws_network_interface.fgt_2_eni_vpc_2.id
  ni_rt_ids = { "bastion-az1" = module.fgt_vpc_2.rt_public_ids["bastion-az1"] }
}




#-----------------------------------------------------------------------
# Necessary variables
#-----------------------------------------------------------------------------------------------------
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}
// Create key-pair
resource "aws_key_pair" "keypair" {
  key_name   = "${local.prefix}-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}