#Example: Existing resource with the latest marketplace image and a public IP enabled for both IPv4 and IPv6

# Paths and Project Information
key_file_path = "key_file.json" # Path to service account key file
project_name  = "project_id"    # GCP project ID
family_name   = "image_family"  # Image family name

# VM and Network Configuration
scanner_region                  = "us-west1"
zone                            = "us-west1-b"
vm_count                        = 2 # Number of VMs to create
virtual_network_new_or_existing = "existing"
virtual_subnet_new_or_existing  = "existing"
image_uri                       = "global_marketplace"

# Scanner and Network Details
scanner_name         = "terraform-scanner" # Scanner VM name
virtual_network_name = "existing_network"  # Name of the existing virtual network
virtual_subnet_name  = "existing_subnet"   # Name of the existing subnet

# Network and IP Configuration
default_firewall_rule = true # Enable default firewall rules
assign_public_ip      = true
assign_ipv6_ip        = true
stack_type            = "IPV4_IPV6" # Specify IP stack type (IPV4_ONLY or IPV4_IPV6)

# Desired VM State and Network Tier
desired_status = "RUNNING" # Desired status of the VM (RUNNING or STOPPED)
network_tier   = "PREMIUM"

# External URLs and Authentication
friendly_name   = "qvsa"                                 # Friendly name for the scanner to be created in qweb
qualysguard_url = "qualysguard.qualys.com"               # URL for QualysGuard platform   
proxy_url       = "user:password@proxy.example.com:8080" # Proxy URL for the scanner
