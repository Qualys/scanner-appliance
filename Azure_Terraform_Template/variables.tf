variable "location" {
  type        = string
  description = "Azure region for resource deployment (e.g., 'eastus'). Refer to the Azure locations documentation: https://azure.microsoft.com/en-in/global-infrastructure/locations/"
}

variable "scanner_name" {
  type        = string
  description = "Defines the name of the scanner VM. Must be 1-63 characters long, consisting of alphanumeric characters, underscores, periods, or hyphens. Special characters are not allowed.\nMore info: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute."

  validation {
    condition     = length(var.scanner_name) >= 1 && length(var.scanner_name) <= 64
    error_message = "Scanner name must be between 1 and 63 characters."
  }
}

variable "scanner_vm_size" {
  type        = string
  default     = "Standard_A2_v2"
  description = "Size of the Scanner VM. Refer to the Azure VM sizes documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes"
}

variable "image_resource" {
  type        = string
  description = <<EOD
Specify one of the following:
- (input_1) qVSA image resource URI
- (input_2) 'global_marketplace'

This value represents the qVSA image, either in the form of an image resource ID URI, or the string 'global_marketplace'. Provide 'global_marketplace' to use latest marketplace image.
EOD
}

variable "os_disk_type" {
  type        = string
  description = <<EOD
Specify the OS disk type. Supported values are:
- 'Premium_LRS'
- 'StandardSSD_LRS'
- 'Standard_LRS'

Note: Premium SSD is supported only by selected VM sizes.
Learn more: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disks-types
EOD

  validation {
    condition     = var.os_disk_type == "Premium_LRS" || var.os_disk_type == "StandardSSD_LRS" || var.os_disk_type == "Standard_LRS"
    error_message = "Allowed values are 'Premium_LRS', 'StandardSSD_LRS', and 'Standard_LRS'."
  }
}

variable "boot_diagnostics" {
  description = "Enable or disable boot diagnostics for VM logging."
  type        = bool
  default     = true
}

variable "is_default_sg" {
  description = "Enable or disable the default security group."
  type        = bool
  default     = true
}

variable "virtual_network_new_or_existing" {
  type        = string
  description = <<EOD
Specify the virtual network for the Scanner VM:
- 'new' for a new virtual network
- 'existing' to use existing virtual network
EOD
}

variable "virtual_resource_group_new_or_existing" {
  type        = string
  description = <<EOD
Specify the virtual network for the Scanner VM:
- 'new' for a new virtual resource group
- 'existing' to use existing resource group
EOD
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group."
  default     = ""
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the Azure virtual network."
  default     = "default-network"
}

variable "virtual_subnet_name" {
  type        = string
  description = "Name of the subnet within the virtual network."
  default     = "default-subnet"
}

variable "security_group_name" {
  type        = string
  description = "Name of the security group."
  default     = ""
}

variable "new_virtual_network" {
  description = "Configuration for the new virtual network."
  type = object({
    name          = string
    address_space = list(string)
  })
  default = {
    name          = "default_vnet"
    address_space = ["10.0.0.0/24", "fd00:db8:deca::/64"]
  }
}

variable "new_subnet" {
  description = "Configuration for the new subnet."
  type = object({
    name             = string
    address_prefixes = list(string)
  })
  default = {
    name             = "default_subnet"
    address_prefixes = ["10.0.0.0/24", "fd00:db8:deca::/64"]
  }
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account."
  default     = ""
}

variable "vm_username" {
  type        = string
  description = "Username for the virtual machine."
  default     = "default-username"
}

variable "vm_password" {
  type        = string
  description = "Password for the virtual machine."
  default     = "default-password"
}

variable "network_interface_name" {
  type        = string
  description = "Name of the network interface."
  default     = "default-interface"
}

variable "qualysguard_url" {
  type        = string
  description = "Specifies the Qualys Guard URL."
}

variable "friendly_name" {
  type        = string
  description = "Defines a user-friendly name for the scanner to be created on qweb."
}

variable "proxy_url" {
  type        = string
  description = "Specifies the proxy for network communication."
  default     = ""
}

variable "vm_count" {
  type        = number
  description = "Number of virtual machines (Scanners) to create."
  default     = 1
}

variable "assign_public_ip" {
  description = "Specify whether to assign an IPv4 address to the VM"
  type        = bool
  default     = false
}

variable "assign_ipv6_public_ip" {
  description = "Specify whether to assign an IPv6 address to the VM."
  type        = bool
  default     = false
}

variable "start_vm" {
  description = "Specify whether to start the VM upon creation."
  type        = bool
  default     = true
}

variable "stop_vm" {
  description = "Specify whether to stop the VM after creation."
  type        = bool
  default     = false
}
variable "proxy_cidr_block" {
  description = "CIDR block for the proxy"
  type        = string
  default     = "0.0.0.0/0"
}
variable "proxy_ipv6_cidr_blocks" {
  description = "IPv6 CIDR block for the proxy"
  type        = string
  default     = "::/0"
}
