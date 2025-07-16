user              = "VSPHERE_USERNAME"
password          = "VSPHERE_PASSWORD"
vsphere_server    = "VSPHERE_SERVER"
remote_ovf_path   = "OVA_URL"
use_userdata      = false # true/false
vm_count          = VM_COUNT
friendly_name     = "VM_FRIENDLY_NAME"
qualysguard_url   = "qualysguard.qualys.com"
compute_cluster   = "COMPUTE_CLUSTER"
datacenter        = "DATACENTER_NAME"
datastore         = "DATASTORE_NAME"
lan_network       = "LAN_NETWORK_NAME"
wan_network       = "WAN_NETWORK_NAME"
vsphere_host      = "VSPHERE_HOST_IP"
disk_provisioning = "DISK_PROVISIONING_TYPE" # e.g., "thin"
disk_label        = "DISK_LABEL"
disk_size         = "DISK_SIZE_GB"
adapter_type      = "ADAPTER_TYPE" # e.g., "vmxnet3"

vm_configs = [
  {
    PREFER_USERDATA      = false # true/false
    num_cpus             = NUM_CPUS
    memory               = MEMORY_MB
    Enable_WAN_Interface = "FALSE" #"True/False"
    LAN_Gateway          = "LAN_GATEWAY_IP"
    LAN_Default_VLAN     = VLAN_ID
    LAN_DNS_Servers      = "DNS_LIST"
    WAN_IP               = "WAN_IP_ADDRESS"
    WAN_Gateway          = "WAN_GATEWAY_IP"
    WAN_DNS_Servers      = "DNS_LIST"
    LAN_Netmask          = "LAN_NETMASK"
    WAN_Netmask          = "WAN_NETMASK"
    WINS_1               = "WINS_SERVER_1"
    WINS_2               = "WINS_SERVER_2"
    WINS_DOMAIN          = "WINS_DOMAIN_NAME"
    LAN_IP               = "LAN_IP_ADDRESS"
    IPV6_ONLY            = "BOOLEAN_STRING"
  },
  {
    PREFER_USERDATA      = false # true/false
    num_cpus             = NUM_CPUS
    memory               = MEMORY_MB
    Enable_WAN_Interface = "FALSE" #"True/False"
    LAN_Gateway          = "LAN_GATEWAY_IP"
    LAN_Default_VLAN     = VLAN_ID
    LAN_DNS_Servers      = "DNS_LIST"
    WAN_IP               = "WAN_IP_ADDRESS"
    WAN_Gateway          = "WAN_GATEWAY_IP"
    WAN_DNS_Servers      = "DNS_LIST"
    LAN_Netmask          = "LAN_NETMASK"
    WAN_Netmask          = "WAN_NETMASK"
    WINS_1               = "WINS_SERVER_1"
    WINS_2               = "WINS_SERVER_2"
    WINS_DOMAIN          = "WINS_DOMAIN_NAME"
    LAN_IP               = "LAN_IP_ADDRESS"
    IPV6_ONLY            = "BOOLEAN_STRING"
    HTTP_Proxy           = "user:password@proxy.example.com:8080"
  }
]
