

# Create log disk for vm customer 1
resource "google_compute_disk" "logdisk-vm-c1" {
  name = "${var.prefix}-log-disk-vm-c1-${random_string.random_name_post.result}"
  size = 30
  type = "pd-standard"
  zone = var.region-1_zone
}

# Create log disk for vm customer 2
resource "google_compute_disk" "logdisk-vm-c2" {
  name = "${var.prefix}-log-disk-vm-c2-${random_string.random_name_post.result}"
  size = 30
  type = "pd-standard"
  zone = var.region-1_zone
}

# Create VM test customer 1
resource "google_compute_instance" "vm-c1" {
  name           = "${var.prefix}-vm-c1"
  machine_type   = var.machine-vm
  zone           = var.region-1_zone

  tags = [
    "${var.prefix}-${var.c1_id}-fwr-private-allow-all",
    "${var.prefix}-${var.c1_id}-route-vm-private"
  ]

 boot_disk {
    initialize_params {
      image = var.image-vm
    }
  }
  attached_disk {
    source = google_compute_disk.logdisk-vm-c1.name
  }
  network_interface {
    subnetwork = module.vpc-c1.subnet_names["private-pro"]
    network_ip = cidrhost(module.vpc-c1.subnet_cidrs["private-pro"],15)
  }
    service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
  metadata = {
    startup-script = <<-EOF
      #! /bin/bash /
      sudo apt-get update
      sudo apt-get install apache2 -y
      sudo a2ensite default-ssl
      sudo a2enmod ssl
      sudo vm_hostname="$(curl -H "Metadata-Flavor:Google" \
      http://169.254.169.254/computeMetadata/v1/instance/name)"
      sudo echo "Page served from: $vm_hostname" | \
      tee /var/www/html/index.html
      sudo systemctl restart apache2"
      EOF
  }
}

# Create VM test spoke2
resource "google_compute_instance" "vm-c2" {
  name           = "${var.prefix}-vm-c2"
  machine_type   = var.machine-vm
  zone           = var.region-1_zone

  tags = [
    "${var.prefix}-${var.c2_id}-fwr-private-allow-all",
    "${var.prefix}-${var.c2_id}-route-vm-private"
  ]

 boot_disk {
    initialize_params {
      image = var.image-vm
    }
  }
  attached_disk {
    source = google_compute_disk.logdisk-vm-c2.name
  }
  network_interface {
    subnetwork = module.vpc-c2.subnet_names["private-pro"]
    network_ip = cidrhost(module.vpc-c2.subnet_cidrs["private-pro"],15)
  }
    service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
  metadata = {
    startup-script = <<-EOF
      #! /bin/bash /
      sudo apt-get update
      sudo apt-get install apache2 -y
      sudo a2ensite default-ssl
      sudo a2enmod ssl
      sudo vm_hostname="$(curl -H "Metadata-Flavor:Google" \
      http://169.254.169.254/computeMetadata/v1/instance/name)"
      sudo echo "Page served from: $vm_hostname" | \
      tee /var/www/html/index.html
      sudo systemctl restart apache2"
      EOF
  }
}
