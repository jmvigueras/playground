# Create log disk for passive
resource "google_compute_disk" "logdisk_passive" {
  name = "${var.prefix}-${var.c_id}-log-disk-passive-${random_string.random_string.result}"
  size = 30
  type = "pd-standard"
  zone = var.region-2_zone
}

########### Instance Related

# Create static passive instance management ip
resource "google_compute_address" "static-passive-mgmt" {
  name = "${var.prefix}-${var.c_id}-passivemgmt-ip"
  region = var.region-2
}

# Create FGTVM compute passive instance
resource "google_compute_instance" "fgt-passive" {
  name           = "${var.prefix}-${var.c_id}-fgt-passive"
  machine_type   = var.machine
  zone           = var.region-2_zone
  can_ip_forward = "true"

  tags = [
    "${var.prefix}-${var.c_id}-fwr-vpc-mgmt-ha-allow-all",
    "${var.prefix}-${var.c_id}-fwr-vpc-ic-1-allow-all",
    "${var.prefix}-${var.c_id}-fwr-vpc-ic-2-allow-all",
    "${var.prefix}-${var.c_id}-fwr-private-allow-all",
    "${var.prefix}-${var.c_id}-route-vm-private"
  ]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  attached_disk {
    source = google_compute_disk.logdisk_passive.name
  }
  network_interface {
    subnetwork = var.subnet_names["mgmt-ha-r2"]
    network_ip = cidrhost(var.subnet_cidrs["mgmt-ha-r2"],11)
    access_config {
      nat_ip = google_compute_address.static-passive-mgmt.address
    }
  }
  network_interface {
    subnetwork = var.subnet_names["ic-1-s2"]
    network_ip = cidrhost(var.subnet_cidrs["ic-1-s2"],11)
  }
  network_interface {
    subnetwork = var.subnet_names["ic-2-s1"]
    network_ip = cidrhost(var.subnet_cidrs["ic-2-s1"],11)
  }
  network_interface {
    subnetwork = var.subnet_names["private-fgt-r2"]
    network_ip = cidrhost(var.subnet_cidrs["private-fgt-r2"],11)
  }

  metadata = {
    user-data = "${data.template_file.setup-passive.rendered}"
  }
  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}

# passive userdata pre-configuration
data "template_file" "setup-passive" {
  template = file("${path.module}/fgt.conf")
  vars = {
    adminsport    = var.adminsport
    fgt_id        = "${var.c_id}-fgt-passive"
    fgt_priority  = "100"

    port1_ip   = cidrhost(var.subnet_cidrs["mgmt-ha-r2"],11)
    port1_mask = cidrnetmask(var.subnet_cidrs["mgmt-ha-r2"])
    port1_net  = var.subnet_cidrs["mgmt-ha-r2"]
    port1_gw   = cidrhost(var.subnet_cidrs["mgmt-ha-r2"],1)

    port2_ip   = cidrhost(var.subnet_cidrs["ic-1-s2"],11)
    port2_mask = cidrnetmask(var.subnet_cidrs["ic-1-s2"])
    port2_net  = var.subnet_cidrs["ic-1-s2"]
    port2_gw   = cidrhost(var.subnet_cidrs["ic-1-s2"],1)

    port3_ip   = cidrhost(var.subnet_cidrs["ic-2-s1"],11)
    port3_mask = cidrnetmask(var.subnet_cidrs["ic-2-s1"])
    port3_net  = var.subnet_cidrs["ic-2-s1"]
    port3_gw   = cidrhost(var.subnet_cidrs["ic-2-s1"],1)

    port4_ip   = cidrhost(var.subnet_cidrs["private-fgt-r2"],11)
    port4_mask = cidrnetmask(var.subnet_cidrs["private-fgt-r2"])
    port4_net  = var.subnet_cidrs["private-fgt-r2"]
    port4_gw   = cidrhost(var.subnet_cidrs["private-fgt-r2"],1)

    peer_hb_ip = cidrhost(var.subnet_cidrs["mgmt-ha-r1"],10)
    
    ic-1-peer_cidr    = var.ic-peer_cidrs["ic-1"]
    ic-2-peer_cidr    = var.ic-peer_cidrs["ic-2"]
    ic-pro-peer_cidr  = var.ic-peer_cidrs["ic-pro"]

    ipsec-psk-key     = var.ipsec-psk-key
    api-key           = var.api-key
    admin-cidr        = var.admin-cidr
    ic-1-peer_ip      = var.ic-peer_ips["ic-1"]
    ic-2-peer_ip      = var.ic-peer_ips["ic-2"]
    ic-peer_ip-hck    = var.ic-peer_ips["ic-hck"]
  }
}

