# Output
output "FortiGate-MGMT-IP" {
  value = {
    mgmt_url = module.fgt-site.*.fgt-site_mgmt-url
    username = "admin"
    password = module.fgt-site.*.password
  }
}


