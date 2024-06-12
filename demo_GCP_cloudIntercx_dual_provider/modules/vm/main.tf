# Create pubic IP for instance
resource "google_compute_address" "instance_pip" {
  name         = "${var.prefix}-instance-pip"
  address_type = "EXTERNAL"
  region       = var.region
}

# Create FGTVM compute active instance
resource "google_compute_instance" "instance" {
  name         = "${var.prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  tags = concat(["${var.subnet_name}-t-route"], ["${var.subnet_name}-t-fwr"], var.tags)

  boot_disk {
    initialize_params {
      image = var.image-vm
    }
  }
  network_interface {
    subnetwork = var.subnet_name
    access_config {
      nat_ip = google_compute_address.instance_pip.address
    }
  }
  metadata = {
    ssh-keys       = "${var.gcp-user_name}:${var.rsa-public-key}"
    startup-script = file("${path.module}/templates/user-data.tpl")
  }
  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}


