variable "container_name" {
  description = "Name of the containerized scanner."
  type        = string
}

variable "image_id" {
  description = "Docker image ID for the Qualys Containerized Scanner Appliance (QCSA)."
  type        = string
}

variable "container_count" {
  description = "Number of containerized scanner instances to create."
  type        = number
  default     = 1
}

variable "deployment_type" {
  description = <<EOD
Defines the type of scanner. Specify one of the following:
- (input_1) resource_limited
- (input_2) resource_unlimited
EOD
  type        = string
  default     = "resource_unlimited"
}

variable "qualysguard_url" {
  description = "URL for accessing the QualysGuard service((qweb)."
  type        = string
}

variable "friendly_name" {
  description = "Friendly name for the scanner instance to be registered on qweb."
  type        = string
  default     = ""
}

variable "private_space_path" {
  description = "Directory path for private space directory"
  type        = string
}

variable "shared_space_path" {
  description = "Directory path for shared space directory"
  type        = string
}

variable "enable_proxy" {
  description = "Whether to creates a containerized scanner with proxy"
  type        = bool
  default     = false
}
variable "https_proxy_user" {
  description = "The username for the HTTPS proxy"
  type        = string
  default     = ""
}

variable "https_proxy_pass" {
  description = "The password for the HTTPS proxy"
  type        = string
  default     = ""
}

variable "https_proxy_host" {
  description = "The host address of the HTTPS proxy"
  type        = string
  default     = ""
}

variable "memory" {
  description = "Memory allocated to the scanner container (e.g., '1g')."
  type        = string
  default     = "1024M"
}

variable "memory_swap" {
  description = "Total memory (memory + swap) allocated to the scanner container (e.g., '2g')."
  type        = string
  default     = "2048M"
}

variable "cpus" {
  description = "Number of CPUs allocated to the scanner container."
  type        = number
  default     = 1
}

variable "private_root_CA" {
  description = "Whether to use a custom root Certificate Authority (CA)."
  type        = bool
  default     = false
}

variable "polling_interval" {
  description = "Job service polling interval (in Seconds) at which the scanner polls for updates. The minimum limit for Job service polling interval is 30 Seconds and maximum limit is 180 seconds."
  type        = number
  default     = null
}

variable "update_interval_min" {
  description = "Update service polling interval  (in minutes) between automatic updates for the scanner. The minimum limit for Update service polling interval is 30 Minutes and maximum limit is 240 Minutes."
  type        = number
  default     = null
}

variable "refresh_interval_min" {
  description = "Platform info service polling interval (in minutes) for refreshing scanner settings or configurations.The minimum limit for Platform info service polling interval is 10 Minutes and maximum limit is 360 Minutes."
  type        = number
  default     = null
}

variable "enable_ipv6" {
  description = "If true, enables IPv6 for the scanner."
  type        = bool
  default     = false
}

variable "ipv6_net_name" {
  description = "Name for the created IPv6 network."
  type        = string
  default     = "ipv6net"
}

variable "create_ipv6_network" {
  description = "If true, creates an IPv6 network."
  type        = bool
  default     = false
}

variable "subnet_range" {
  description = "Specifies the subnet range for the scanner's network."
  type        = string
  default     = ""
}

variable "stop_containers" {
  description = "If true, the scanner containers will be stopped if no scan is running on generated containers."
  type        = bool
  default     = false
}

variable "stop_and_delete_container_scanners" {
  description = "If true, the containers will be stopped if no scan is running on generated containers scanners and scanners will be deleted from qweb."
  type        = bool
  default     = false
}
