output "Username" {
  value = var.adminusername
}

output "Password" {
  value = var.adminpassword
}

output "api_key" {
  value = random_string.api_key.result
}

