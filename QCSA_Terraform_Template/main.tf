locals {
  activation_codes = jsondecode(data.local_file.userdata.content)
  scanner          = var.deployment_type
  friendly_name    = var.friendly_name == "" ? var.container_name : var.friendly_name
}

data "local_file" "userdata" {
  depends_on = [null_resource.fetch_activation_codes]
  filename   = "./userdata.json"
}

resource "null_resource" "create_scanner_containers" {
  count = var.container_count
  provisioner "local-exec" {
    command = <<EOT
    docker run -d \
      -v ${var.shared_space_path}:/usr/local/qualys:z \
      -v ${var.private_space_path}/${local.activation_codes.activation_ids[count.index]}:/usr/local/qualys/admin/etc:z \
      --name ${var.container_name}-${count.index + 1}\
      ${var.deployment_type == "resource_limited" && var.memory != "" && var.memory_swap != "" && var.cpus != "" ? "--memory ${var.memory} --memory-swap ${var.memory_swap} --cpus ${var.cpus}" : ""} \
      ${var.private_root_CA ? "-v /root/rootcert:/usr/local/bin:z" : ""} \
      -e PERSONALIZATION_CODE=${local.activation_codes.activation_ids[count.index]} \
      ${var.enable_ipv6 == true && var.ipv6_net_name != "" ? "--network ${var.ipv6_net_name}" : ""} \
      -e QUALYS_URL=${var.qualysguard_url} \
      ${var.enable_proxy == true ? "-e HTTPS_PROXY=${var.https_proxy_user}:${var.https_proxy_pass}@${var.https_proxy_host}" : ""} \
      ${var.polling_interval != null ? "-e SCAND_POLL_INTERVAL_SEC=${var.polling_interval}" : ""} \
      ${var.update_interval_min != null ? "-e UPDATE_INTERVAL_MIN=${var.update_interval_min}" : ""} \
      ${var.refresh_interval_min != null ? "-e REFRESH_INTERVAL_MIN=${var.refresh_interval_min}" : ""} \
      ${var.image_id}
    EOT
  }
  depends_on = [null_resource.create_private_space_dir]
}

resource "null_resource" "fetch_activation_codes" {
  count = var.container_count
  provisioner "local-exec" {
    command = "./get_activation_code.sh ${var.container_count} ${count.index} ${var.qualysguard_url} ${local.friendly_name}"
  }
}

resource "null_resource" "create_private_space_dir" {
  count = var.stop_and_delete_container_scanners ? 0 : var.container_count
  provisioner "local-exec" {
    command = "mkdir -p ${var.private_space_path}/${local.activation_codes.activation_ids[count.index]}"
  }
  depends_on = [null_resource.fetch_activation_codes]
}

resource "null_resource" "stop_container" {
  count = (var.stop_containers || var.stop_and_delete_container_scanners) ? var.container_count : 0
  provisioner "local-exec" {
    command = "./stop_containers.sh ${var.container_count} ${count.index} ${var.qualysguard_url} ${var.container_name} ${local.friendly_name} ${var.stop_and_delete_container_scanners}"
  }
  depends_on = [null_resource.create_scanner_containers]
}

resource "null_resource" "create_ipv6_network" {
  count = var.create_ipv6_network ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
    docker network create --ipv6 --subnet ${var.subnet_range} ${var.ipv6_net_name}
    EOT
  }
}
