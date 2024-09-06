# Example: New resources with custom names, a public IP disabled for both IPv4 and IPv6, and using a locally stored image URI

# Paths and Project Information
key_file_path = "key_file.json" #Path to service account key file
project_name  = "project_id"    #GCP project ID
family_name   = "image_family"

# VM and Network Configuration
scanner_region                  = "us-west1"
zone                            = "us-west1-b"
vm_count                        = 2 # Number of VMs to create
virtual_network_new_or_existing = "new"
virtual_subnet_new_or_existing  = "new"
image_uri                       = "projects/project-id/global/images/image-name" #local_image_uri_placeholder

# Scanner and Network Details
scanner_name         = "terraform-scanner"
virtual_network_name = "testnet"    # Name of the new virtual network
virtual_subnet_name  = "testsubnet" # Name of the new subnet

# Network and IP Configuration
default_firewall_rule = true
assign_public_ip      = false
assign_ipv6_ip        = false

# Desired VM State and Network Tier
desired_status = "RUNNING" # Desired status of the VM (RUNNING or STOPPED)
network_tier   = "PREMIUM"

# External URLs and Authentication
friendly_name   = "qvsa"                                 # Friendly name for the scanner to be created in qweb
qualysguard_url = "qualysguard.qualys.com"               # URL for QualysGuard platform   
proxy_url       = "user:password@proxy.example.com:8080" # Proxy URL for the scanner

