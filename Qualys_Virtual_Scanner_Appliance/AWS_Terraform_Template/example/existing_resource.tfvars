# Example: Creation of a virtual scanner using existing resources, a marketplace AMI, a security group, ignore AMI changes set to true.

# General Configuration
aws_region            = "us-east-1"
availability_zone     = "us-east-1b"
scanner_instance_type = "t3.large"
scanner_name          = "terraform-test"
ignore_ami_changes    = true
# Number of VMs to create
vm_count       = 1
instance_state = "running"

# Network and Security Configuration 
vpc_id            = "existing_vpc_id"
virtual_subnet_id = "existing_subnet_id"
security_group_id = "existing_security_group_id"

# IP Address Configuration
assign_public_ip      = true
assign_ipv6_public_ip = false

# Marketplace Image and QualysGuard Configuration
ami             = "global_marketplace"
friendly_name   = "qvsa"                                 # Friendly name for the scanner to be created in qweb
qualysguard_url = "qualysguard.qualys.com"               # URL for QualysGuard platform   
proxy_url       = "user:password@proxy.example.com:8080" # Proxy URL for the scanner
