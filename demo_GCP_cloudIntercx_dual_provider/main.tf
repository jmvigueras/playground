#------------------------------------------------------------------------------------------------------------
# Necessary variables
#------------------------------------------------------------------------------------------------------------
// GET deploy public IP for management
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}

data "google_client_openid_userinfo" "me" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = ".ssh/ssh-key.pem"
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