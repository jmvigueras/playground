# Output
output "FortiGate-MGMT-IP" {
  value = {
    mgmt_url = module.fgt-site.*.fgt-site_mgmt-url
    username = "admin"
    password = module.fgt-site.*.password
  }
}

output "TestVM" {
  value = {
    public_ip  = module.fgt-site.*.vm-test_public-ip
    private_ip = module.fgt-site.*.vm-test_private-ip
  }
}