locals {
  is_rg_new           = contains(["new", ""], var.virtual_resource_group_new_or_existing) ? 1 : 0
  is_vnet_new         = contains(["new", ""], var.virtual_network_new_or_existing) ? 1 : 0
  is_public_ip        = var.assign_public_ip ? 1 : 0
  image_uri           = contains(["global_marketplace"], var.image_resource) ? 1 : 0
  resource_group_name = local.is_rg_new == 1 ? length(var.resource_group_name) > 0 ? "${var.resource_group_name}" : "${var.scanner_name}-vrgt-${random_integer.random_num.result}" : var.resource_group_name
  v_net_name          = local.is_vnet_new == 1 ? var.new_virtual_network.name : var.virtual_network_name
  subnet_name         = local.is_vnet_new == 1 ? var.new_subnet.name : var.virtual_subnet_name
  resource_group      = local.is_rg_new == 1 ? azurerm_resource_group.example[0].id : data.azurerm_resource_group.existing_rg[0].id
  v_net               = local.is_vnet_new == 1 ? azurerm_virtual_network.example[0].id : data.azurerm_virtual_network.existing_vnet[0].id
  subnet              = local.is_vnet_new == 1 ? azurerm_subnet.example[0].id : data.azurerm_subnet.existing_subnet[0].id
  boot_diag_uri       = var.boot_diagnostics ? data.azurerm_storage_account.existing-acc[0].primary_blob_endpoint : null
  security_group      = var.is_default_sg ? azurerm_network_security_group.example[0].id : data.azurerm_network_security_group.existing[0].id
  security_group_name = !var.is_default_sg ? var.security_group_name : ""
  templates           = [for i in range(var.vm_count) : file("./userdata/userdata_${i}.txt")]
  proxy_port          = regex(":(\\d+)$", var.proxy_url)[0]
  is_proxy_defined    = length(var.proxy_url) > 0
}

resource "random_integer" "random_num" {
  min = 1000
  max = 9999
}

resource "azurerm_resource_group" "example" {
  count    = local.is_rg_new
  name     = local.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "existing_rg" {
  count = local.is_rg_new == 0 ? 1 : 0
  name  = local.resource_group_name
}

resource "azurerm_virtual_network" "example" {
  count               = local.is_vnet_new
  name                = local.v_net_name
  location            = var.location
  resource_group_name = local.resource_group_name
  address_space       = var.new_virtual_network.address_space
  depends_on = [
    azurerm_resource_group.example
  ]
}

data "azurerm_virtual_network" "existing_vnet" {
  count               = local.is_vnet_new == 0 ? 1 : 0
  name                = local.v_net_name
  resource_group_name = local.resource_group_name
  depends_on = [
    data.azurerm_resource_group.existing_rg
  ]
}

resource "azurerm_subnet" "example" {
  count                = local.is_vnet_new
  name                 = local.subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.v_net_name
  address_prefixes     = var.new_subnet.address_prefixes
  depends_on = [
    azurerm_virtual_network.example
  ]
}

data "azurerm_subnet" "existing_subnet" {
  count                = local.is_vnet_new == 0 ? 1 : 0
  name                 = local.subnet_name
  virtual_network_name = local.v_net_name
  resource_group_name  = local.resource_group_name
  depends_on = [
    data.azurerm_virtual_network.existing_vnet
  ]
}

data "azurerm_storage_account" "existing-acc" {
  count               = var.boot_diagnostics ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = "saregressionRG"
}

resource "azurerm_network_interface" "example" {
  count               = var.vm_count
  name                = "${var.network_interface_name}${count.index}"
  location            = var.location
  resource_group_name = local.resource_group_name

  #This IP configuration for the IPv4 address 
  ip_configuration {
    name                          = "v4config"
    private_ip_address_version    = "IPv4"
    primary                       = "true"
    subnet_id                     = local.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.IPv4_Public_IP[count.index].id : null
  }

  #This IP configuration for the IPv6 address 
  dynamic "ip_configuration" {
    for_each = var.assign_public_ip && var.assign_ipv6_public_ip ? [1] : []
    content {
      name                          = "v6config"
      private_ip_address_version    = "IPv6"
      subnet_id                     = local.subnet
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.IPv6_Public_IP[count.index].id
    }
  }

}

#Create a v4 Public IP
resource "azurerm_public_ip" "IPv4_Public_IP" {
  count               = var.assign_public_ip ? var.vm_count : 0
  name                = "new_ipv4-${count.index}"
  resource_group_name = local.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv4"
  depends_on          = [local.resource_group]
}

#Create a v6 Public IP
resource "azurerm_public_ip" "IPv6_Public_IP" {
  count               = var.assign_public_ip && var.assign_ipv6_public_ip ? var.vm_count : 0
  name                = "ipv6-${count.index}"
  resource_group_name = local.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv6"
  depends_on          = [local.resource_group]
}

resource "azurerm_network_security_group" "example" {
  count               = var.is_default_sg ? 1 : 0
  name                = "default-sg"
  location            = var.location
  resource_group_name = local.resource_group_name

  // Allow outbound traffic on port 443 for ipv4
  security_rule {
    name                       = "AllowHTTPSOutbound"
    description                = "Allow all outbound traffic on port 443"
    protocol                   = "Tcp"
    source_port_range          = "443"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 1002
    direction                  = "Outbound"
  }
  // Allow outbound traffic on port 443 for ipv6
  security_rule {
    name                       = "AllowHTTPSOutbound"
    description                = "Allow all outbound traffic on port 443"
    protocol                   = "Tcp"
    source_port_range          = "443"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 1002
    direction                  = "Outbound"
  }
  // Conditionally allow inbound traffic if a proxy port is defined for ipv4
  dynamic "security_rule" {
    for_each = local.is_proxy_defined ? [1] : []
    content {
      name                       = "AllowProxyInbound"
      description                = "Allow inbound traffic on proxy port"
      protocol                   = "Tcp"
      source_port_range          = local.proxy_port
      source_address_prefix      = var.proxy_cidr_block
      destination_port_range     = local.proxy_port
      destination_address_prefix = var.proxy_cidr_block
      access                     = "Allow"
      priority                   = 1003
      direction                  = "Inbound"
    }
  }
  // Conditionally allow inbound traffic if a proxy port is defined for ipv6
  dynamic "security_rule" {
    for_each = local.is_proxy_defined ? [1] : []
    content {
      name                       = "AllowProxyInbound"
      description                = "Allow inbound traffic on proxy port"
      protocol                   = "Tcp"
      source_port_range          = local.proxy_port
      source_address_prefix      = var.proxy_ipv6_cidr_blocks
      destination_port_range     = local.proxy_port
      destination_address_prefix = var.proxy_ipv6_cidr_blocks
      access                     = "Allow"
      priority                   = 1003
      direction                  = "Inbound"
    }
  }
  depends_on = [
    azurerm_resource_group.example
  ]
}

data "azurerm_network_security_group" "existing" {
  count               = var.is_default_sg ? 0 : 1
  name                = local.security_group_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_network_interface_security_group_association" "example" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.example[count.index].id
  network_security_group_id = local.security_group
}

resource "azurerm_linux_virtual_machine" "scanner_vm" {
  count                           = var.vm_count
  name                            = "${var.scanner_name}-${count.index}"
  location                        = var.location
  resource_group_name             = local.resource_group_name
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
    azurerm_resource_group.example
  ]
  user_data = base64encode(local.templates[count.index])
}

# Null resource to start the VM
resource "null_resource" "start_vm" {
  count = var.start_vm ? var.vm_count : 0
  provisioner "local-exec" {
    command = "az vm start --resource-group ${local.resource_group_name} --name ${var.scanner_name}-${count.index}"
  }
  depends_on = [azurerm_linux_virtual_machine.scanner_vm]
}

# Null resource to stop the VM
resource "null_resource" "stop_vm" {
  count = var.stop_vm ? var.vm_count : 0
  provisioner "local-exec" {
    command = "az vm deallocate --resource-group ${local.resource_group_name} --name ${var.scanner_name}-${count.index}"
  }
  depends_on = [azurerm_linux_virtual_machine.scanner_vm]
}
