#  Example : new scanner VM creation along with creation of new resources with custom name provided, boot diagnostics enabled, latest marketplace image 

# General Configuration
location         = "eastus"
vm_count         = 2 # Number of VMs to create
scanner_name     = "terraform-scanner"
start_vm         = true
boot_diagnostics = true

# Resource Group and Network Configuration
virtual_network_new_or_existing        = "new"
virtual_resource_group_new_or_existing = "new"
resource_group_name                    = "test-rg"
network_interface_name                 = "test-interface"

new_virtual_network = {
  name          = "test-vnet"
  address_space = ["10.0.0.0/24", "fd00:db8:deca::/64"]
}

new_subnet = {
  name             = "test-subnet"
  address_prefixes = ["10.0.0.0/24", "fd00:db8:deca::/64"]
}

# VM and Storage Configuration
os_disk_type         = "StandardSSD_LRS"
storage_account_name = "test-storage-account"

# IP Address Configuration
assign_public_ip      = true
assign_ipv6_public_ip = true

# Marketplace Image and QualysGuard Configuration
image_resource  = "global_marketplace"
friendly_name   = "qvsa"                                 # Friendly name for the scanner to be created in qweb
qualysguard_url = "qualysguard.qualys.com"               # URL for QualysGuard platform   
proxy_url       = "user:password@proxy.example.com:8080" # Proxy URL for the scanner
