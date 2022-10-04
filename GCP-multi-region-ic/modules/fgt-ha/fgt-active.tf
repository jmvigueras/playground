resource "random_string" "random_string" {
  length                 = 3
  special                = false
  numeric                = true
  upper                  = false
}

# Create log disk for active
resource "google_compute_disk" "logdisk_active" {
  name = "${var.prefix}-${var.c_id}-log-disk-active-${random_string.random_string.result}"
  size = 30
  type = "pd-standard"
  zone = var.region-1_zone
}

########### Instance Related

# Create static active instance management ip
resource "google_compute_address" "static-active-mgmt" {
  name = "${var.prefix}-${var.c_id}-activemgmt-ip"
  region = var.region-1
}

# Create FGTVM compute active instance
resource "google_compute_instance" "fgt-active" {
  name           = "${var.prefix}-${var.c_id}-fgt-active"
  machine_type   = var.machine
  zone           = var.region-1_zone
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
    source = google_compute_disk.logdisk_active.name
  }
  network_interface {
    subnetwork = var.subnet_names["mgmt-ha-r1"]
    network_ip = cidrhost(var.subnet_cidrs["mgmt-ha-r1"],10)
    access_config {
      nat_ip = google_compute_address.static-active-mgmt.address
    }
  }
  network_interface {
    subnetwork = var.subnet_names["ic-1-s1"]
    network_ip = cidrhost(var.subnet_cidrs["ic-1-s1"],10)
  }
  network_interface {
    subnetwork = var.subnet_names["ic-2-s2"]
    network_ip = cidrhost(var.subnet_cidrs["ic-2-s2"],10)
  }
  network_interface {
    subnetwork = var.subnet_names["private-fgt-r1"]
    network_ip = cidrhost(var.subnet_cidrs["private-fgt-r1"],10)
  }

  metadata = {
    user-data = "${data.template_file.setup-active.rendered}"
  }
  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}

# active userdata pre-configuration
data "template_file" "setup-active" {
  template = file("${path.module}/fgt.conf")
  vars = {
    adminsport    = var.adminsport
    api-key       = var.api-key
    admin-cidr    = var.admin-cidr

    fgt_id        = "${var.c_id}-fgt-active"
    fgt_priority  = "200"

    port1_ip   = cidrhost(var.subnet_cidrs["mgmt-ha-r1"],10)
    port1_mask = cidrnetmask(var.subnet_cidrs["mgmt-ha-r1"])
    port1_net  = var.subnet_cidrs["mgmt-ha-r1"]
    port1_gw   = cidrhost(var.subnet_cidrs["mgmt-ha-r1"],1)

    port2_ip   = cidrhost(var.subnet_cidrs["ic-1-s1"],10)
    port2_mask = cidrnetmask(var.subnet_cidrs["ic-1-s1"])
    port2_net  = var.subnet_cidrs["ic-1-s1"]
    port2_gw   = cidrhost(var.subnet_cidrs["ic-1-s1"],1)

    port3_ip   = cidrhost(var.subnet_cidrs["ic-2-s2"],10)
    port3_mask = cidrnetmask(var.subnet_cidrs["ic-2-s2"])
    port3_net  = var.subnet_cidrs["ic-2-s2"]
    port3_gw   = cidrhost(var.subnet_cidrs["ic-2-s2"],1)

    port4_ip   = cidrhost(var.subnet_cidrs["private-fgt-r1"],10)
    port4_mask = cidrnetmask(var.subnet_cidrs["private-fgt-r1"])
    port4_net  = var.subnet_cidrs["private-fgt-r1"]
    port4_gw   = cidrhost(var.subnet_cidrs["private-fgt-r1"],1)

    peer_hb_ip        = cidrhost(var.subnet_cidrs["mgmt-ha-r2"],11)
    
    ipsec-psk-key     = var.ipsec-psk-key
    private-pro_cidr  = var.subnet_cidrs["private-pro"]

    ic-1-peer_cidr    = var.ic-peer_cidrs["ic-1"]
    ic-2-peer_cidr    = var.ic-peer_cidrs["ic-2"]
    ic-pro-peer_cidr  = var.ic-peer_cidrs["ic-pro"]
    ic-1-peer_ip      = var.ic-peer_ips["ic-1"]
    ic-2-peer_ip      = var.ic-peer_ips["ic-2"]
    ic-peer_ip-hck    = var.ic-peer_ips["ic-hck"]
  }
}