# Local values to determine the configuration
locals {
  isGlobalMktImage = (var.image_uri == "") || (var.image_uri == "global_marketplace")
  selected_image   = local.isGlobalMktImage ? data.google_compute_image.global_marketplace_image[0].self_link : var.image_uri
  templates        = [for i in range(var.vm_count) : file("./userdata/userdata_${i}.json")]
}

data "google_compute_network" "existing_network" {
  name = var.virtual_network_name
}

data "google_compute_subnetwork" "existing_subnetwork" {
  name   = var.virtual_subnet_name
  region = var.scanner_region
}

# Fetch the global marketplace image
data "google_compute_image" "global_marketplace_image" {
  count   = local.isGlobalMktImage ? 1 : 0
  project = "qualys-gcp-security"
  family  = "qvsa"
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
  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }

  network_interface {
    network    = data.google_compute_network.existing_network.self_link
    subnetwork = data.google_compute_subnetwork.existing_subnetwork.self_link
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

resource "null_resource" "userdata_cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf userdata"
  }
}
