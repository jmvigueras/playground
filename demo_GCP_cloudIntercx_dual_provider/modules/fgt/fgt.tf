#------------------------------------------------------------------------------------------------------------
# FGT ACTIVE VM
#------------------------------------------------------------------------------------------------------------
# Create new random str
resource "random_string" "randon_str" {
  length  = 5
  special = false
  numeric = true
  upper   = false
}
# Create log disk for active
resource "google_compute_disk" "logdisk" {
  name = "${var.prefix}-fgt-1-log-disk-${random_string.randon_str.result}"
  size = 30
  type = "pd-standard"
  zone = var.zone1
}

# Create static passive instance management ip
resource "google_compute_address" "public-ip" {
  name         = "${var.prefix}-public-ip"
  address_type = "EXTERNAL"
  region       = var.region
}

# Create FGTVM compute active instance
resource "google_compute_instance" "fgt" {
  name           = "${var.prefix}-fgt"
  machine_type   = var.machine
  zone           = var.zone1
  can_ip_forward = "true"

  tags = ["${var.subnet_names["mgmt"]}-t-fwr", "${var.subnet_names["public"]}-t-fwr", "${var.subnet_names["private"]}-t-fwr"]

  boot_disk {
    initialize_params {
      image = var.license_type == "byol" ? data.google_compute_image.fgt_image_byol.self_link : data.google_compute_image.fgt_image_payg.self_link
    }
  }
  attached_disk {
    source = google_compute_disk.logdisk.name
  }
  network_interface {
    subnetwork = var.subnet_names["public"]
    network_ip = var.fgt-ni_ips["public"]
    access_config {
      nat_ip = google_compute_address.public-ip.address
    }

    dynamic "alias_ip_range" {
      for_each = { for k, v in var.alias_ip_ranges : k => v if k == "public" }
      content {
        ip_cidr_range = alias_ip_range.value
      }
    }
  }
  network_interface {
    subnetwork = var.subnet_names["private"]
    network_ip = var.fgt-ni_ips["private"]
    
    dynamic "alias_ip_range" {
      for_each = { for k, v in var.alias_ip_ranges : k => v if k == "private" }
      content {
        ip_cidr_range = alias_ip_range.value
      }
    }
  }

  metadata = {
    ssh-keys  = trimspace("${var.gcp-user_name}:${var.rsa-public-key}")
    user-data = var.fgt_config
    license   = fileexists("${var.license_file}") ? "${file(var.license_file)}" : null
  }
  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }
  scheduling {
    preemptible       = false
    automatic_restart = true
  }
}

#------------------------------------------------------------------------------------------------------------
# Images
#------------------------------------------------------------------------------------------------------------
data "google_compute_image" "fgt_image_payg" {
  project = "fortigcp-project-001"
  filter  = "name=fortinet-fgtondemand-${var.fgt_version}*"
}

data "google_compute_image" "fgt_image_byol" {
  project = "fortigcp-project-001"
  filter  = "name=fortinet-fgt-${var.fgt_version}*"
}