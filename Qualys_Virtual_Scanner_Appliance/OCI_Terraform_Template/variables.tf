variable "tenancy_ocid" {
  type = string
  description = "The OCID of your tenancy in OCI."
}

variable "user_ocid" {
  type = string
  description = "The OCID of the user performing the operations."
}

variable "fingerprint" {
  type = string
  description = "The fingerprint of the public API key associated with the user."
}

variable "private_key_path" {
  type = string
  description = "The local file path to the user's private API key."
}

variable "oci_region" {
  type        = string
  description = "The region in which resources will be created"
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment"
}

variable "availability_domain" {
  type        = string
  description = "The availability domain for the instance"
}

variable "image_ocid" {
  type        = string
  description = "The OCID of the image to use for the instance"
}

variable "shape" {
  type        = string
  description = "The shape of the instance"
}

variable "scanner_name" {
  type        = string
  description = "The display name of the instance"
}

variable "subnet_id" {
  type        = string
  description = "The OCID of the subnet where the instance will be launched"
}


variable "vm_count" {
  type        = number
  description = "Number of instances to create" 
}

variable "memory_in_gbs" {
  type = number
  description = "If a flexible shape (e.g., VM.Standard.E5.Flex) is selected, memory_in_gbs will be explicitly allocated to the scanner; otherwise, the shape's default memory will be used."
  default = 4
}

variable "ocpus" {
  type = number
  description = "If a flexible shape (e.g., VM.Standard.E5.Flex) is selected, ocpus number of ocpus will be explicitly allocated to the scanner; otherwise, the shape's default ocpus will be used."
  default = 1
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether to assign a public IP4 address to the VM."
  default     = false
}

variable "assign_ipv6_public_ip" {
  type        = bool
  description = "Whether to assign an IPv6 address to the VM."
  default     = false
}

variable "friendly_name" {
  type        = string
  description = "Friendly name for the scanner."
}

variable "qualysguard_url" {
  type        = string
  description = "QualysGuard URL for scanner configuration."
}

variable "proxy_url" {
  type        = string
  description = "Optional: Proxy URL for the scanner to use."
  default     = ""
}

variable "platform_type" {
  description = "The type of platform to use for the instance (AMD_VM, INTEL_VM, ARM_VM)"
  type        = string
  default     = "AMD_VM"  # Optional default
}

variable "enable_smt" {
  type = bool
  description = <<EOT
Controls whether Simultaneous Multithreading (SMT) is enabled on the instance.
- true: SMT is enabled — each core runs multiple threads (e.g., 2 threads per core).
- false: SMT is disabled — each core runs a single thread.
EOT
  default = true
}

variable "legacy_imds_endpoints_disabled" {
  type = bool
  description = <<EOT
Controls whether legacy instance metadata service (IMDSv1) endpoints are disabled.
- true: IMDSv1 is disabled — only IMDSv2 is available (more secure; requires Authorization header).
- false: IMDSv1 is enabled — both IMDSv1 and IMDSv2 are available, allowing backward compatibility.
EOT

  default = true
}