# Output
output "FGT-IPs" {
  value = {
    fgt-c1-active   = module.fgt-c1.FortiGate-HA-Master-MGMT-IP
    fgt-c1-passive  = module.fgt-c1.FortiGate-HA-Slave-MGMT-IP
    fgt-c2-active   = module.fgt-c2.FortiGate-HA-Master-MGMT-IP
    fgt-c2-passive  = module.fgt-c2.FortiGate-HA-Slave-MGMT-IP
  }
}

output "FGT-Username" {
  value = "admin"
}

output "FGT-Password-default" {
  value = {
    fgt-c1-active = module.fgt-c1.FortiGate-Password
    fgt-c2-active = module.fgt-c2.FortiGate-Password
  }
}

