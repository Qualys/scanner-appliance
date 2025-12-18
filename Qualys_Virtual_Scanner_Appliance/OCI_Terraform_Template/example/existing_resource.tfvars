private_key_path   = "/root/.oci/private_key.pem"

# General Configuration
oci_region             = "us-ashburn-1"
compartment_ocid   = "ocid1.tenancy.oc1..aaaaaaaaxxxxxxxxxxxxx"
availability_domain = "Lhkx:US-ASHBURN-AD-1"
image_ocid         = "" # provide the image OCID directly (e.g., image_ocid = "ocid1.image.oc1..aaaaaaaaxxxxxxxxxxxxx") or set image_ocid = "global_marketplace" to use a Marketplace image
shape              = "VM.Standard.E4.Flex"
scanner_name          = "terraform-scanner"

# Network Configuration 
subnet_id          = "ocid1.subnet.oc1..aaaaaaaaxxxxxxxxxxxxx"

# Number of VMs to create
vm_count       = 1

# Configuration of scanner if flexible shape is selected (Note: Recommended OCPU-to-RAM ratio is 1:4)
memory_in_gbs = 4
ocpus         = 1

# IP Address Configuration
assign_public_ip      = false
assign_ipv6_public_ip = false


# QualysGuard Configuration
friendly_name   = "qvsa"                                 # Friendly name for the scanner to be created in qweb (max 19 chars).
qualysguard_url = "qualysguard.qualys.com"               # URL for QualysGuard platform   

# Proxy Details
proxy_url       = "user:password@proxy.example.com:8080" # Proxy URL for the scanner

# Platform Configuration
platform_type = "AMD_VM"                                 # default platform type 
enable_smt = false

# Instance Metadata Service (IMDS) Option
legacy_imds_endpoints_disabled = true
