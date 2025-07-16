locals {
  templates = [for i in range(var.vm_count) : file("./userdata/userdata_${i}.txt")]

  existing_availabilty_domain = length([
    for ad in data.oci_identity_availability_domains.all_availability_domains.availability_domains :
    ad.name
    if ad.name == var.availability_domain
  ]) > 0 ? var.availability_domain : ""

  existing_subnet_id = length([
    for subnet in data.oci_core_subnets.all_subnets.subnets :
      subnet.id
      if subnet.id == var.subnet_id
  ]) > 0 ? var.subnet_id : ""

  existing_image_id = length([
    for img in data.oci_core_images.all_images.images :
    img.id
    if img.id == var.image_ocid
  ]) > 0 ? var.image_ocid : ""

}


data "oci_core_subnets" "all_subnets" {
  compartment_id = var.compartment_ocid
} 

data "oci_identity_availability_domains" "all_availability_domains" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "all_images" {
  compartment_id = var.compartment_ocid
}


resource "oci_core_instance" "vm_instance" {
  count = var.vm_count
  availability_domain = local.existing_availabilty_domain
  compartment_id      = var.compartment_ocid
  shape               = var.shape
  display_name        = "${var.scanner_name}-${count.index}"

  create_vnic_details {
    subnet_id = local.existing_subnet_id
    assign_public_ip = var.assign_public_ip
    assign_ipv6ip = var.assign_ipv6_public_ip
  }

  metadata = {
    user_data = base64encode(local.templates[count.index])
  }

  dynamic "shape_config" {
    for_each = can(regex("flex", lower(var.shape))) ? [1] : []
    content {
      memory_in_gbs = var.memory_in_gbs
      ocpus         = var.ocpus
    }
  }
  platform_config {
    type = var.platform_type
    is_symmetric_multi_threading_enabled = var.enable_smt
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = var.legacy_imds_endpoints_disabled
  }

  source_details {
    source_type = "image"
    source_id   = local.existing_image_id
  }
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf userdata"
  }
}