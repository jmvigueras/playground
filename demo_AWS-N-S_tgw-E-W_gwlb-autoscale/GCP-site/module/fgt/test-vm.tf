# Create vm public ip
resource "google_compute_address" "vm-public-ip" {
  name = "${var.prefix}-${var.site_id}-vm-public-ip"
}

# Create FGTVM compute active instance
resource "google_compute_instance" "vm-test" {
  name         = "${var.prefix}-${var.site_id}-vm-test"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["${var.prefix}-${var.site_id}-t-fwr-fgt-spoke1", "${var.prefix}-${var.site_id}-t-route-vm-spoke1"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.spoke1-subnet.name
    network_ip = cidrhost(cidrsubnet(var.vpc-site_net, 4, 4), 15)
    access_config {
      nat_ip = google_compute_address.vm-public-ip.address
    }
  }
  metadata = {
    //ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"
    //ssh-keys = "jvigueras:${var.rsa-public-key}"
    ssh-keys = var.ssh-keys
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}

