
# Local values to determine the configuration
locals {
  is_new_network     = contains(["new", ""], var.virtual_network_new_or_existing) ? 1 : 0
  is_new_subnet      = contains(["new", ""], var.virtual_subnet_new_or_existing) ? 1 : 0
  vnet_name          = contains(["new", ""], var.virtual_network_new_or_existing) ? length(var.virtual_network_name) > 0 ? "${var.virtual_network_name}" : "${var.scanner_name}-vnet-${random_integer.random_num.result}" : var.virtual_network_name
  vsubnet_name       = contains(["new", ""], var.virtual_subnet_new_or_existing) ? length(var.virtual_subnet_name) > 0 ? "${var.virtual_subnet_name}" : "${var.scanner_name}-vsubnet-${random_integer.random_num.result}" : var.virtual_subnet_name
  isGlobalMktImage   = (var.image_uri == "") || (var.image_uri == "global_marketplace")
  selected_image     = local.isGlobalMktImage ? data.google_compute_image.global_marketplace_image[0].self_link : var.image_uri
  network            = contains(["new", ""], var.virtual_network_new_or_existing) ? google_compute_network.example[0].self_link : data.google_compute_network.existing_network[0].self_link
  subnetwork         = contains(["new", ""], var.virtual_subnet_new_or_existing) ? google_compute_subnetwork.example[0].self_link : data.google_compute_subnetwork.existing_subnetwork[0].self_link
  templates          = [for i in range(var.vm_count) : file("./userdata/userdata_${i}.json")]
  proxy_port         = regex(":(\\d+)$", var.proxy_url)[0]
  is_proxy_defined   = length(var.proxy_url) > 0
  ipv4_range         = var.assign_public_ip ? ["0.0.0.0/0"] : []
  ipv6_range         = var.assign_public_ip && var.assign_ipv6_ip ? ["::/0"] : []
  destination_ranges = concat(local.ipv4_range, local.ipv6_range)
}

resource "random_integer" "random_num" {
  min = 1000
  max = 9999
}

resource "google_compute_network" "example" {
  count                   = local.is_new_network
  name                    = local.vnet_name
  auto_create_subnetworks = false
}

data "google_compute_network" "existing_network" {
  count = local.is_new_network == 0 ? 1 : 0
  name  = var.virtual_network_name
}

resource "google_compute_subnetwork" "example" {
  count            = local.is_new_subnet
  name             = local.vsubnet_name
  ip_cidr_range    = var.subnet_cidr
  network          = google_compute_network.example[0].self_link
  region           = var.scanner_region
  stack_type       = var.assign_ipv6_ip ? "IPV4_IPV6" : "IPV4_ONLY"
  ipv6_access_type = var.assign_ipv6_ip ? "EXTERNAL" : null

}

data "google_compute_subnetwork" "existing_subnetwork" {
  count  = local.is_new_subnet == 0 ? 1 : 0
  name   = var.virtual_subnet_name
  region = var.scanner_region
}

# Fetch the global marketplace image
data "google_compute_image" "global_marketplace_image" {
  count   = local.isGlobalMktImage ? 1 : 0
  project = "qualys-gcp-security"
  family  = "qvsa"
}

resource "google_compute_firewall" "allow_https_outbound" {
  count       = var.default_firewall_rule ? 1 : 0
  name        = "allow-https-outbound"
  description = "Allow outbound traffic on port 443"

  network = var.virtual_network_name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction          = "EGRESS"
  priority           = 1002
  destination_ranges = ["0.0.0.0/0"]
  source_ranges      = ["0.0.0.0/0"]
  depends_on         = [local.network]
}

resource "google_compute_firewall" "allow_https_outbound_ipv6" {
  count       = var.default_firewall_rule ? 1 : 0
  name        = "allow-https-outbound-ipv6"
  description = "Allow outbound traffic on port 443 for IPv6"

  network = var.virtual_network_name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction          = "EGRESS"
  priority           = 1003
  destination_ranges = ["::/0"]
  source_ranges      = ["::/0"]
  depends_on         = [local.network]
}

resource "google_compute_firewall" "allow_proxy_inbound" {
  count       = local.is_proxy_defined ? 1 : 0
  name        = "allow-proxy-inbound"
  description = "Allow inbound traffic on proxy port"
  network     = var.virtual_network_name
  allow {
    protocol = "tcp"
    ports    = [local.proxy_port]
  }

  direction          = "INGRESS"
  priority           = 1003
  destination_ranges = [var.proxy_cidr_block]
  source_ranges      = [var.proxy_cidr_block]
  depends_on         = [local.network]
}

resource "google_compute_firewall" "allow_proxy_inbound_ipv6" {
  count       = local.is_proxy_defined ? 1 : 0
  name        = "allow-https-inbound-ipv6"
  description = "Allow inbound traffic on proxy port"
  network     = var.virtual_network_name
  allow {
    protocol = "tcp"
    ports    = [local.proxy_port]
  }

  direction          = "INGRESS"
  priority           = 1003
  destination_ranges = [var.proxy_ipv6_cidr_blocks]
  source_ranges      = [var.proxy_ipv6_cidr_blocks]
  depends_on         = [local.network]
}

# Create the VM instance
resource "google_compute_instance" "vm_instance" {
  count        = var.vm_count
  name         = "${var.scanner_name}-${count.index}"
  machine_type = var.scanner_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = local.selected_image
    }
  }

  network_interface {
    network    = local.network
    subnetwork = local.subnetwork
    stack_type = var.assign_public_ip ? var.stack_type : null
    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        network_tier = var.network_tier
      }
    }
    dynamic "ipv6_access_config" {
      for_each = (var.assign_public_ip && var.assign_ipv6_ip) ? [1] : []
      content {
        network_tier = "PREMIUM"
      }
    }
  }
  metadata       = jsondecode(local.templates[count.index])
  desired_status = var.desired_status
}
