variable "zone" {
  type        = string
  description = "Specifies the deployment zone (e.g., us-west1-b).\nMore info: https://cloud.google.com/compute/docs/regions-zones."
}

variable "scanner_name" {
  type        = string
  description = "Defines the name of the scanner VM. Must be 1-63 characters long, consisting of alphanumeric characters, underscores, periods, or hyphens. Special characters are not allowed.\nMore info: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute."

  validation {
    condition     = length(var.scanner_name) >= 1 && length(var.scanner_name) <= 64
    error_message = "Scanner name must be between 1 and 63 characters."
  }
}

variable "scanner_machine_type" {
  type        = string
  description = "Specifies the machine type for the scanner VM.\nMore info: https://cloud.google.com/compute/docs/general-purpose-machines."
  default     = "e2-medium"
}

variable "project_name" {
  type        = string
  description = "Defines the Google Cloud project name.\nMore info: https://cloud.google.com/resource-manager/docs/creating-managing-projects."
}

variable "family_name" {
  type        = string
  description = "Specifies the image family name for the scanner VM.\nMore info: https://cloud.google.com/compute/docs/images/image-families-best-practices."
}

variable "scanner_region" {
  type        = string
  description = "Specifies the region for deployment (e.g., us-west1).\nMore info: https://cloud.google.com/compute/docs/regions-zones."
}

variable "key_file_path" {
  type        = string
  description = "Specifies the file path for the service account key.\nMore info: https://cloud.google.com/iam/docs/keys-create-delete."
}

variable "virtual_network_new_or_existing" {
  type        = string
  description = "Defines whether to create a new virtual network or use an existing one. Provide 'new' for a new network or 'existing' for existing network."
}

variable "virtual_subnet_new_or_existing" {
  type        = string
  description = "Defines whether to create a new subnet or use an existing one. Provide 'new' for a new subnet or 'existing' for an existing subnet."
}

variable "virtual_network_name" {
  type        = string
  description = "Specifies the name of the virtual network."
  default     = "default-virtual-network"
}

variable "virtual_subnet_name" {
  type        = string
  description = "Specifies the name of the virtual subnet."
  default     = "default-subnet"
}

variable "subnet_cidr" {
  type        = string
  description = "Defines the CIDR range for the subnet. Default is 10.0.0.0/24."
  default     = "10.0.0.0/24"
}

variable "image_uri" {
  type        = string
  description = "Specifies the image URI for the scanner VM. Provide either the local image URI or 'global_marketplace'."
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
  description = "Specifies the proxy URL for network communication."
  default     = ""
}

variable "vm_count" {
  type        = number
  description = "Defines the number of scanner VMs to create."
  default     = 1
}

variable "assign_public_ip" {
  type        = bool
  description = "Determines whether to assign a public IPv4 address to the VM."
  default     = false
}

variable "assign_ipv6_ip" {
  type        = bool
  description = "Determines whether to assign an IPv6 address to the VM."
  default     = false
}

variable "default_firewall_rule" {
  description = "Determines whether to use the default firewall rules or an existing rule."
  type        = bool
  default     = true
}

variable "desired_status" {
  description = "Specifies the desired operational status of the VM instances (e.g., RUNNING or TERMINATED)."
  type        = string
  default     = "RUNNING"
}

variable "network_tier" {
  description = "Specifies the network tier for the VM instances (e.g., PREMIUM or STANDARD)."
  type        = string
  default     = "STANDARD"
}

variable "stack_type" {
  description = "Specifies the IP stack type for the VM instances (e.g., IPV4_ONLY or IPV4_IPV6)."
  type        = string
  default     = "IPV4_ONLY"
}

variable "proxy_cidr_block" {
  description = "CIDR block for the proxy"
  type        = string
  default     = "0.0.0.0/0"
}
variable "proxy_ipv6_cidr_blocks" {
  description = "IPV6 CIDR block for the proxy"
  type        = string
  default     = "::/0"
}
