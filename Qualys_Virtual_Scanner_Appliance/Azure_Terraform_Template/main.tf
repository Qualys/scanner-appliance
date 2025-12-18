locals {
  is_public_ip  = var.assign_public_ip ? 1 : 0
  image_uri     = contains(["global_marketplace"], var.image_resource) ? 1 : 0
  boot_diag_uri = var.boot_diagnostics ? data.azurerm_storage_account.existing-acc[0].primary_blob_endpoint : null
  templates     = [for i in range(var.vm_count) : file("./userdata/userdata_${i}.txt")]
}

data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "existing_vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  depends_on = [
    data.azurerm_resource_group.existing_rg
  ]
}

data "azurerm_subnet" "existing_subnet" {
  name                 = var.virtual_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
  depends_on = [
    data.azurerm_virtual_network.existing_vnet
  ]
}

data "azurerm_storage_account" "existing-acc" {
  count               = var.boot_diagnostics ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface" "example" {
  count               = var.vm_count
  name                = "${var.network_interface_name}${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  #This IP configuration for the IPv4 address 
  ip_configuration {
    name                          = "v4config"
    private_ip_address_version    = "IPv4"
    primary                       = "true"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.IPv4_Public_IP[count.index].id : null
  }

  #This IP configuration for the IPv6 address 
  dynamic "ip_configuration" {
    for_each = var.assign_public_ip && var.assign_ipv6_public_ip ? [1] : []
    content {
      name                          = "v6config"
      private_ip_address_version    = "IPv6"
      subnet_id                     = data.azurerm_subnet.existing_subnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.IPv6_Public_IP[count.index].id
    }
  }

}

#Create a v4 Public IP
resource "azurerm_public_ip" "IPv4_Public_IP" {
  count               = var.assign_public_ip ? var.vm_count : 0
  name                = "new_ipv4-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv4"
  depends_on          = [data.azurerm_resource_group.existing_rg]
}

#Create a v6 Public IP
resource "azurerm_public_ip" "IPv6_Public_IP" {
  count               = var.assign_public_ip && var.assign_ipv6_public_ip ? var.vm_count : 0
  name                = "ipv6-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv6"
  depends_on          = [data.azurerm_resource_group.existing_rg]
}

data "azurerm_network_security_group" "existing" {
  name                = var.security_group_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface_security_group_association" "example" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.example[count.index].id
  network_security_group_id = data.azurerm_network_security_group.existing.id
}

resource "azurerm_linux_virtual_machine" "scanner_vm" {
  count                           = var.vm_count
  name                            = "${var.scanner_name}-${count.index}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.scanner_vm_size
  admin_username                  = "${var.vm_username}${count.index}"
  admin_password                  = "${var.vm_password}${count.index}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }
  dynamic "source_image_reference" {
    for_each = local.image_uri == 1 ? [1] : []
    content {
      publisher = "qualysguard"
      offer     = "qualys-virtual-scanner"
      sku       = "qvsa"
      version   = "latest"
    }
  }
  dynamic "plan" {
    for_each = local.image_uri == 1 ? [1] : []
    content {
      name      = "qvsa"
      product   = "qualys-virtual-scanner"
      publisher = "qualysguard"
    }
  }
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics ? [1] : []
    content {
      storage_account_uri = local.boot_diag_uri
    }
  }
  source_image_id = local.image_uri != 1 ? var.image_resource : null
  depends_on = [
    azurerm_network_interface.example,
    data.azurerm_resource_group.existing_rg
  ]
  user_data = base64encode(local.templates[count.index])
}

# Null resource to start the VM
resource "null_resource" "start_vm" {
  count = var.start_vm ? var.vm_count : 0
  provisioner "local-exec" {
    command = "az vm start --resource-group ${var.resource_group_name} --name ${var.scanner_name}-${count.index}"
  }
  depends_on = [azurerm_linux_virtual_machine.scanner_vm]
}

# Null resource to stop the VM
resource "null_resource" "stop_vm" {
  count = var.stop_vm ? var.vm_count : 0
  provisioner "local-exec" {
    command = "az vm deallocate --resource-group ${var.resource_group_name} --name ${var.scanner_name}-${count.index}"
  }
  depends_on = [azurerm_linux_virtual_machine.scanner_vm]
}

resource "null_resource" "userdata_cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf userdata"
  }
}
