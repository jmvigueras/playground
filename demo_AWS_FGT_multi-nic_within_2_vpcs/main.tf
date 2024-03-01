#-----------------------------------------------------------------------------------------------------
# Create VPC 1 and FGT cluster
#-----------------------------------------------------------------------------------------------------
# Create VPC 1
module "fgt_vpc" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.5"

  prefix     = "${local.prefix}-vpc-1"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.fgt_vpc_cidr

  public_subnet_names  = local.fgt_vpc_public_subnet_names
  private_subnet_names = local.fgt_vpc_private_subnet_names
}
# Create FGT NIs
module "fgt_nis" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_ni_sg"
  version = "0.0.5"

  prefix = "${local.prefix}-vpc-1"
  azs    = local.azs

  vpc_id      = module.fgt_vpc.vpc_id
  subnet_list = module.fgt_vpc.subnet_list

  fgt_subnet_tags = local.fgt_subnet_tags

  fgt_number_peer_az = local.fgt_number_peer_az
  cluster_type       = local.fgt_cluster_type
}
# Create FGTs config
module "fgt_config" {
  for_each = { for k, v in local.fgt_ports_config : k => v }

  //source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_config"
  //version = "0.0.5"

  source = "./modules/fgt_config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  ports_config = each.value

  config_fgcp       = local.fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.fgt_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = local.fgt_ports_config

  default_private_port = "${local.fgt_private_port_prefix}1"
  fgsp_port            = "${local.fgt_private_port_prefix}1"
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
#-----------------------------------------------------------------------------------------------------
# Create VPC SPOKEs, ENI and VM test
#-----------------------------------------------------------------------------------------------------
# Create VPC SPOKES
module "spoke_vpc" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.5"

  for_each = local.spoke_vpc_cidr

  prefix     = "${local.prefix}-${each.key}"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = each.value

  public_subnet_names  = local.spoke_vpc_public_subnet_names
  private_subnet_names = local.spoke_vpc_private_subnet_names
}
# Create test VM in each VPC spoke and in each AZ
module "spoke_vpc_vm" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vm"
  version = "0.0.5"

  for_each = { for i, pair in setproduct(range(0, local.spoke_vpc_number), range(0, length(local.azs))) : "spoke${pair[0] + 1}.az${pair[1] + 1}" => "spoke${pair[0] + 1}" }

  prefix          = "${local.prefix}-${each.key}"
  keypair         = aws_key_pair.keypair.key_name
  subnet_id       = module.spoke_vpc[each.value].subnet_ids[element(split(".", each.key), 1)]["vm"]
  subnet_cidr     = module.spoke_vpc[each.value].subnet_cidrs[element(split(".", each.key), 1)]["vm"]
  security_groups = [module.spoke_vpc[each.value].sg_ids["default"]]
}

#-----------------------------------------------------------------------------------------------------
# Create FGT ENIs in VPC SPOKEs
# 
resource "aws_network_interface" "fgt_eni_spoke_vpc" {
  for_each = { for i, pair in setproduct(range(0, local.spoke_vpc_number), range(0, length(local.azs))) : "spoke${pair[0] + 1}.az${pair[1] + 1}" => "spoke${pair[0] + 1}" }

  subnet_id       = module.spoke_vpc[each.value].subnet_ids[element(split(".", each.key), 1)]["fgt"]
  security_groups = [module.spoke_vpc[each.value].sg_ids["default"]]
  private_ip_list = [cidrhost(module.spoke_vpc[each.value].subnet_cidrs[element(split(".", each.key), 1)]["fgt"], 10)]

  source_dest_check       = false
  private_ip_list_enabled = true

  tags = { Name = "${local.prefix}-${each.key}-${"${element(split(".", each.key), 1)}-fgt1"}-private-ni" }
}
# Attach ENI to FGT1
resource "aws_network_interface_attachment" "fgt_1_eni_spoke_vpc" {
  for_each = { for i, pair in setproduct(range(0, local.spoke_vpc_number), range(0, length(local.azs))) :
    "spoke${pair[0] + 1}.az${pair[1] + 1}" => {
      "fgt_key"  = "az${pair[1] + 1}.fgt1"
      "ni_index" = length(local.fgt_vpc_public_subnet_names) + length(local.fgt_vpc_private_subnet_names) + pair[0]
    }
  }

  instance_id          = module.fgt.fgt_peer_az_ids[each.value["fgt_key"]]
  network_interface_id = aws_network_interface.fgt_eni_spoke_vpc[each.key].id
  device_index         = each.value["ni_index"]
}
#-----------------------------------------------------------------------------------------------------
# Update routes VPC
# 
# Update private RT route RFC1918 cidrs to FGT NI
module "spoke_vpc_routes" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.5"

  for_each = { for i in range(0, local.spoke_vpc_number) : "spoke${i + 1}.az1" => "spoke${i + 1}" }

  ni_id     = aws_network_interface.fgt_eni_spoke_vpc[each.key].id
  ni_rt_ids = { for i, k in local.azs : "vm-az${i + 1}" => module.spoke_vpc[each.value].rt_public_ids["vm-az${i + 1}"] }
}

#-----------------------------------------------------------------------------------------------------
# Complete FGT ports config to use in others modules
# -----------------------------------------------------------------------------------------------------
locals {
  fgt_private_port_prefix = "spoke"
  fgt_ports_config = { for k, v in module.fgt_nis.fgt_ports_config :
    k => concat(v, [
      for i, pair in setproduct(range(0, local.spoke_vpc_number), range(0, length(local.azs))) :
      {
        "port" = "port${length(local.fgt_vpc_public_subnet_names) + length(local.fgt_vpc_private_subnet_names) + pair[0] + 1}",
        "ip"   = cidrhost(module.spoke_vpc["spoke${pair[0] + 1}"].subnet_cidrs["az${pair[1] + 1}"]["fgt"], 10),
        "mask" = cidrnetmask(module.spoke_vpc["spoke${pair[0] + 1}"].subnet_cidrs["az${pair[1] + 1}"]["fgt"]),
        "gw"   = cidrhost(module.spoke_vpc["spoke${pair[0] + 1}"].subnet_cidrs["az${pair[1] + 1}"]["fgt"], 1),
        "tag"  = "${local.fgt_private_port_prefix}${pair[0] + 1}"
      } if element(split(".", k),0) == "az${pair[1] + 1}"
      ] 
    )
  }
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