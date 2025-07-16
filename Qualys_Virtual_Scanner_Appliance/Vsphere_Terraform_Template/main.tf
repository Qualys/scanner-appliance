data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.compute_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "lan" {
  name          = var.lan_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "wan" {
  name          = var.wan_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "null_resource" "generate_perscodes" {
  count = var.use_userdata ? 0 : 1
  triggers = {
    vm_count = var.vm_count
  }
  provisioner "local-exec" {
    command = "bash ./generate_perscode.sh ${var.vm_count} ${var.friendly_name} ${var.qualysguard_url}"
  }
}

data "local_file" "perscode_json" {
  count      = var.use_userdata ? 0 : 1
  depends_on = [null_resource.generate_perscodes]
  filename   = "./userdata.json"
}

locals {
  perscode_list       = var.use_userdata ? [] : jsondecode(data.local_file.perscode_json[0].content)
  user_data_templates = var.use_userdata ? [for i in range(var.vm_count) : file("./userdata/userdata_${i}.txt")] : []
}

resource "vsphere_virtual_machine" "vm" {
  for_each = {
    for idx, vm in var.vm_configs :
    idx => merge(vm, { index = idx })
  }
  name             = "${var.friendly_name}-${each.value.index}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  datacenter_id    = data.vsphere_datacenter.dc.id
  num_cpus         = each.value.num_cpus
  memory           = each.value.memory

  disk {
    label            = var.disk_label
    size             = var.disk_size
    thin_provisioned = true
  }

  ovf_deploy {
    remote_ovf_url    = var.remote_ovf_path
    disk_provisioning = var.disk_provisioning
    ovf_network_map = {
      "LAN" = data.vsphere_network.lan.id
      "WAN" = data.vsphere_network.wan.id
    }
  }

  network_interface {
    network_id   = data.vsphere_network.lan.id
    adapter_type = var.adapter_type
  }
  network_interface {
    network_id   = data.vsphere_network.wan.id
    adapter_type = var.adapter_type
  }

  vapp {
    properties = merge({
      Enable_WAN_Interface = lookup(each.value, "Enable_WAN_Interface", null)
      LAN_Gateway          = lookup(each.value, "LAN_Gateway", null)
      LAN_Default_VLAN     = lookup(each.value, "LAN_Default_VLAN", null)
      LAN_DNS_Servers      = lookup(each.value, "LAN_DNS_Servers", null)
      WAN_IP               = lookup(each.value, "WAN_IP", null)
      WAN_Gateway          = lookup(each.value, "WAN_Gateway", null)
      WAN_DNS_Servers      = lookup(each.value, "WAN_DNS_Servers", null)
      PREFER_USERDATA      = lookup(each.value, "PREFER_USERDATA", null)
      LAN_Netmask          = lookup(each.value, "LAN_Netmask", null)
      WAN_Netmask          = lookup(each.value, "WAN_Netmask", null)
      WINS_1               = lookup(each.value, "WINS_1", null)
      WINS_2               = lookup(each.value, "WINS_2", null)
      WINS_DOMAIN          = lookup(each.value, "WINS_DOMAIN", null)
      HTTP_Proxy           = lookup(each.value, "HTTP_Proxy", null)
      LAN_IP               = lookup(each.value, "LAN_IP", null)
      IPV6_ONLY            = lookup(each.value, "IPV6_ONLY", null)
      },
      var.use_userdata ? {
        USER_DATA            = base64encode(local.user_data_templates[each.value.index])
        Personalization_Code = ""
        } : {
        USER_DATA            = ""
        Personalization_Code = local.perscode_list[each.value.index]
    })
  }
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
}

resource "null_resource" "cleanup" {

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf userdata.json userdata"
  }
}
