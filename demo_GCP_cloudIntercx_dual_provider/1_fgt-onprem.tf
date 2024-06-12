#------------------------------------------------------------------------------------------------------------
# Create VPCs and subnets Fortigate
#
module "onprem_vpc" {
  source = "./modules/vpc_fgt"

  region = local.region
  prefix = "${local.prefix}-onprem"

  vpc-sec_cidr = local.onprem_vpc_cidr
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#
module "onprem_config" {
  source = "./modules/fgt_config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_cidrs = module.onprem_vpc.subnet_cidrs
  fgt_ni_ips   = module.onprem_vpc.fgt-active-ni_ips

  fgt_extra-config = join("\n", [
    data.template_file.onprem_fw_policy.rendered,
    data.template_file.onprem_secondary_ip.rendered
    ]
  )

  config_hub = true
  hub        = local.onprem_hub

  vpc-spoke_cidr = [module.onprem_vpc.subnet_cidrs["bastion"]]
}
# Extra config allow all firewall policy
data "template_file" "onprem_fw_policy" {
  template = templatefile("./templates/fgt_fw_policy.conf", {
    port = "port1"
  })
}
# Extra config secondary IP Fortigate
data "template_file" "onprem_secondary_ip" {
  template = templatefile("./templates/fgt_xlb-config.conf", {
    port   = "port2"
    ilb_ip = module.onprem_vpc.fgt-passive-ni_ips["private"]
  })
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster instances
#
module "onprem" {
  source = "./modules/fgt"

  prefix = "${local.prefix}-onprem"
  region = local.region
  zone1  = local.zone1
  zone2  = local.zone2

  machine        = local.instance_type
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]
  license_type   = local.license_type
  fgt_version    = local.fgt_version

  subnet_names = module.onprem_vpc.subnet_names
  fgt-ni_ips   = module.onprem_vpc.fgt-active-ni_ips

  alias_ip_ranges = { "private" = "${module.onprem_vpc.fgt-passive-ni_ips["private"]}/32" }

  fgt_config = module.onprem_config.fgt_config
}
#------------------------------------------------------------------------------------------------------------
# - create Bastion VM
#
# Create Bastion
module "onprem_bastion" {
  source = "./modules/vm"

  prefix = "${local.prefix}-onprem"
  region = local.region
  zone   = local.zone1

  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]

  subnet_name = module.onprem_vpc.subnet_names["bastion"]
  tags        = ["zone1"]
}
# Create routes
resource "google_compute_route" "onprem_bastion_route" {
  depends_on = [module.onprem_vpc]

  name        = "${local.prefix}-tag-route-peer"
  dest_range  = "172.16.0.0/12"
  network     = module.onprem_vpc.vpc_names["private"]
  next_hop_ip = module.onprem_vpc.fgt-active-ni_ips["private"]
  priority    = 100
  tags        = ["zone1"]
}











