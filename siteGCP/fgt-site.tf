# Create log disk for active
resource "google_compute_disk" "logdisk" {
  name = "${var.prefix}-log-disk"
  size = 30
  type = "pd-standard"
  zone = var.zone
}

########### Instance Related

# active userdata pre-configuration
data "template_file" "setup-site" {
  template = file("${path.module}/config-site.conf")
  vars = {
    admin_port = var.admin_port
    admin_cidr = var.admin_cidr
    
    port1_ip   = cidrhost(cidrsubnet(var.vpc-site_net,4,1),10)
    port1_mask = cidrnetmask(cidrsubnet(var.vpc-site_net,4,1))
    port1_net  = cidrsubnet(var.vpc-site_net,4,1)
    port1_gw   = google_compute_subnetwork.mgmt-subnet.gateway_address
    port2_ip   = cidrhost(cidrsubnet(var.vpc-site_net,4,2),10)
    port2_mask = cidrnetmask(cidrsubnet(var.vpc-site_net,4,2))
    port2_net  = cidrsubnet(var.vpc-site_net,4,2)
    port2_gw   = google_compute_subnetwork.public-subnet.gateway_address
    port3_ip   = cidrhost(cidrsubnet(var.vpc-site_net,4,3),10)
    port3_mask = cidrnetmask(cidrsubnet(var.vpc-site_net,4,3))
    port3_net  = cidrsubnet(var.vpc-site_net,4,3)
    port3_gw   = google_compute_subnetwork.private-subnet.gateway_address
    port4_ip   = cidrhost(cidrsubnet(var.vpc-site_net,4,4),10)
    port4_mask = cidrnetmask(cidrsubnet(var.vpc-site_net,4,4))
    port4_net  = cidrsubnet(var.vpc-site_net,4,4)
    port4_gw   = google_compute_subnetwork.spoke1-subnet.gateway_address

    spoke1-net           = cidrsubnet(var.vpc-site_net,4,4)

    advpn-ipsec-psk      = var.advpn-ipsec-psk

    site_bgp-asn         = var.site["bgp-asn"]
    site_advpn-ip1       = var.site["advpn-ip1"]
    site_advpn-ip2       = var.site["advpn-ip2"]

    hub1_bgp-asn         = var.hub1["bgp-asn"]
    hub1_public-ip1      = var.hub1["public-ip1"]
    hub1_advpn-ip1       = var.hub1["advpn-ip1"]
    hub1_hck-srv-ip1     = var.hub1["hck-srv-ip1"]
    hub1_cidr            = var.hub1["cidr"]

    hub2_bgp-asn         = var.hub2["bgp-asn"]
    hub2_public-ip1      = var.hub2["public-ip1"]
    hub2_advpn-ip1       = var.hub2["advpn-ip1"]
    hub2_hck-srv-ip1     = var.hub2["hck-srv-ip1"]
    hub2_cidr            = var.hub2["cidr"]
  }
}

# Create static cluster ip
resource "google_compute_address" "static-public-ip" {
  name = "${var.prefix}-public-ip"
}

# Create static active instance management ip
resource "google_compute_address" "static-mgmt-ip" {
  name = "${var.prefix}-mgmt-ip"
}

# Create FGTVM compute active instance
resource "google_compute_instance" "fgt-site" {
  name           = "${var.prefix}-fgt-site"
  machine_type   = var.machine
  zone           = var.zone
  can_ip_forward = "true"

  tags = ["${var.prefix}-t-fwr-ftg-mgmt","${var.prefix}-t-fwr-ftg-public","${var.prefix}-t-fwr-fgt-private","${var.prefix}-t-fwr-fgt-spoke1"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  attached_disk {
    source = google_compute_disk.logdisk.name
  }
  network_interface {
    subnetwork = google_compute_subnetwork.mgmt-subnet.name
    network_ip = cidrhost(cidrsubnet(var.vpc-site_net,4,1),10)
    access_config {
      nat_ip = google_compute_address.static-mgmt-ip.address
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.public-subnet.name
    network_ip = cidrhost(cidrsubnet(var.vpc-site_net,4,2),10)
    access_config {
      nat_ip = google_compute_address.static-public-ip.address
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.private-subnet.name
    network_ip = cidrhost(cidrsubnet(var.vpc-site_net,4,3),10)

  }
  network_interface {
    subnetwork = google_compute_subnetwork.spoke1-subnet.name
    network_ip = cidrhost(cidrsubnet(var.vpc-site_net,4,4),10)
  }

  metadata = {
    user-data = "${data.template_file.setup-site.rendered}"
    license   = fileexists("${path.module}/${var.licenseFile}") ? "${file(var.licenseFile)}" : null
  }
  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}