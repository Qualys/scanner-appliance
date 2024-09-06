#  Example : new scanner VM creation along with creation of new resources with default configurations

# General Configuration
location         = "eastus"
vm_count         = 2 # Number of VMs to create
scanner_name     = "terraform-scanner"
start_vm         = true
stop_vm          = false
boot_diagnostics = false

# Resource Group and Network Configuration
virtual_network_new_or_existing        = "new"
virtual_resource_group_new_or_existing = "new"

# VM and Storage Configuration
os_disk_type = "StandardSSD_LRS"

# IP Address Configuration
assign_public_ip      = false
assign_ipv6_public_ip = false

# Marketplace Image and QualysGuard Configuration
image_resource  = "/subscriptions/azure_subscription_id/resourceGroups/resource-group-name/providers/Microsoft.Compute/images/image-name" #local_image_uri_placeholder
friendly_name   = "qvsa"                                                                                                                  # Friendly name for the scanner to be created in qweb
qualysguard_url = "qualysguard.qualys.com"                                                                                                # URL for QualysGuard platform                                                                                                  # URL for QualysGuard platform   
proxy_url       = "user:password@proxy.example.com:8080"                                                                                  # Proxy URL for the scanner# Proxy URL for the scanner
