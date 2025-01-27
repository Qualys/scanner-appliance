#  Example : new scanner VM creation using exisiting resources, boot diagnostics enabled, public IP4 assigned

# General Configuration
location = "eastus"
# Number of VMs to create
vm_count         = 2
scanner_name     = "terraform-scanner"
start_vm         = true
stop_vm          = false
boot_diagnostics = true

# Resource Group and Network Configuration
resource_group_name    = "test-rg"
network_interface_name = "test-interface"
virtual_network_name   = "existing-vnet-name"
virtual_subnet_name    = "existing-subnet-name"

# VM and Storage Configuration
os_disk_type         = "StandardSSD_LRS"
storage_account_name = "test-storage-account"
security_group_name  = "existing-security-group-name"

# IP Address Configuration
assign_public_ip      = true
assign_ipv6_public_ip = false

# Marketplace Image and QualysGuard Configuration
image_resource  = "global_marketplace"
friendly_name   = "qvsa"                                 # Friendly name for the scanner to be created in qweb
qualysguard_url = "qualysguard.qualys.com"               # URL for QualysGuard platform   
proxy_url       = "user:password@proxy.example.com:8080" # Proxy URL for the scanner
