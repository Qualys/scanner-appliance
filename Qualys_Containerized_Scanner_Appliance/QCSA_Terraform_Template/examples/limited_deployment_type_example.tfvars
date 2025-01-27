# Example: Create a new Resource-limited containerized scanner with IPv6 networking support,including the creation of a new IPv6 network. Custom values are set for polling_interval, update_interval_min, and refresh_interval_min.The example includes container parameters for stopping and deleting provisioning.


image_id = "image_id" # Identifier for the image.
# Specifies the deployment type. Valid options: "resource_limited" or "resource_unlimited"".
deployment_type = "resource_limited"
# Name of the container.
container_name = "terraform-scanner"
# Number of containers to deploy.
container_count = 2
#Bind mount a private directory at /usr/local/qualys/admin/etc on a containerized scanner.
private_space_path = "private/space/path"
#Bind mount a shared directory at /usr/local/qualys on the containerized scanner.
shared_space_path = "shared/space/path"
# URL of the QualysGuard service.
qualysguard_url = "https://qualysguard.qualys.com"
# User-friendly name for the scanner in the Qualys web interface.
friendly_name = "qcsa"
# Indicates whether to enable proxy settings. Set to `true` to enable or `false` to disable.
enable_proxy = true
# Polling interval in seconds.
polling_interval = 60
# Minimum update interval in minutes.
update_interval_min = 50
# Minimum refresh interval in minutes.
refresh_interval_min = 40
# Enables IPv6 networking. Set to `true` to enable or `false` to disable.
enable_ipv6 = true
# Specifies if a new IPv6 network should be created. Set to `true` to create or `false` otherwise.
create_ipv6_network = true
# Name of the IPv6 network.
ipv6_net_name = "ipv6net"
# Subnet range for the IPv6 network.
subnet_range = "2001:db8::/64"
# Determines whether containers should be stopped and the container scanner deleted from the Qualys web interface. Set to `true` or `false`.
stop_and_delete_container_scanners = false
