#  Example : New Resource-unlimited containerized scanner creation with disabled support for both IPv6 Networking and proxy.The example includes parameters for stopping conayiners.

image_id = "image_id"
# Specifies the type of deployment. Possible values are "Limited" or "Unlimited".
deployment_type = "resource_unlimited"
container_name  = "terraform-scanner"
container_count = 1
#Bind mount a private directory at /usr/local/qualys/admin/etc on a containerized scanner.
private_space_path = "private/space/path"
#Bind mount a shared directory at /usr/local/qualys on the containerized scanner.
shared_space_path = "shared/space/path"
# URL of the QualysGuard service.
qualysguard_url = "https://qualysguard.qualys.com"
# Friendly name of scanner appliance created on qweb.
friendly_name = "qcsa"
# Indicates whether a proxy should be enabled. Set to true to enable the proxy, false to disable.
enable_proxy = false
# Enables IPv6 networking. Set to true to enable, false to disable.
enable_ipv6 = false
# Determines whether containers should be stopped. If true, only docker containers will be stopped and not deleting scanner container on qweb.Set to `true` or `false`.
stop_containers = false

