variable "user" {
  type        = string
  description = "vSphere username used for authentication."
}

variable "password" {
  type        = string
  description = "vSphere password used for authentication."
}

variable "vsphere_server" {
  type        = string
  description = "FQDN or IP address of the vSphere server."
}

variable "remote_ovf_path" {
  type        = string
  description = "Path to the local or remote OVA file used for VM deployment."
}

variable "datacenter" {
  type        = string
  description = "Name of the vSphere datacenter where resources will be deployed."
}

variable "compute_cluster" {
  type        = string
  description = "Name of the compute cluster within the datacenter."
}

variable "datastore" {
  type        = string
  description = "Name of the datastore to be used for storing VM files."
}

variable "lan_network" {
  type        = string
  description = "Name of the LAN port group or network."
}

variable "wan_network" {
  type        = string
  description = "Name of the WAN port group or network."
}

variable "vsphere_host" {
  type        = string
  description = "IP address or hostname of the vSphere ESXi host."
}

variable "disk_provisioning" {
  type        = string
  description = "Disk provisioning type (e.g., 'thin', 'thick')."
}

variable "disk_label" {
  type        = string
  description = "Label assigned to the virtual disk."
}

variable "disk_size" {
  type        = string
  description = "Size of the virtual disk in GB."
}

variable "adapter_type" {
  type        = string
  description = "Type of network adapter (e.g., vmxnet3, e1000)."
}

variable "vm_count" {
  type        = number
  description = "Number of virtual machines to deploy."
  default     = 1
}

variable "friendly_name" {
  type        = string
  description = "Prefix used to generate human-readable VM names for easier identification."
}

variable "qualysguard_url" {
  type        = string
  description = "QualysGuard platform URL used for scanner configuration."
}

variable "use_userdata" {
  type        = string
  description = "Flag to enable or disable usage of cloud-init userdata (`True` or `False`)."
}

variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    num_cpus             = number
    memory               = number
    Enable_WAN_Interface = optional(string)
    LAN_Gateway          = optional(string)
    LAN_Default_VLAN     = optional(string)
    LAN_DNS_Servers      = optional(string)
    WAN_IP               = optional(string)
    WAN_Gateway          = optional(string)
    WAN_DNS_Servers      = optional(string)
    PREFER_USERDATA      = optional(string)
    LAN_Netmask          = optional(string)
    WAN_Netmask          = optional(string)
    WINS_1               = optional(string)
    WINS_2               = optional(string)
    WINS_DOMAIN          = optional(string)
    HTTP_Proxy           = optional(string)
    LAN_IP               = optional(string)
    IPV6_ONLY            = optional(string)
    user_data            = optional(string)
    Personalization_Code = optional(string)
  }))
}
