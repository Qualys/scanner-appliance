# Deploy Qualys Containerized Scanner Appliance

- [main.tf](./main.tf)
- [variable.tf](./variables.tf)

## Deploy using Terraform
This configuration file sets up and customizes a Containerized Scanner with specific parameters for its environment and operation.
### Prerequisite

1. **Terraform Installation**: Install Terraform by following the instructions provided in the [official terraform documentation](https://developer.hashicorp.com/terraform/install).

2. **QCSA Image Configuration**: Ensure the QCSA image is properly configured. Refer to the [QCSA Image Configuration Guide](https://docs.qualys.com/en/scanner/qcsa/create_qcs/qcsa_image_config.htm) for detailed instructions.


## Steps for Deployment

1. **Set Environment Variables**  
   Export the necessary QualysGuard credentials to authenticate and interact with Qualys APIs:

   ```shell
   export QUALYSGUARD_LOGIN="your_qualysguard_username"
   export QUALYSGUARD_PASSWORD="your_qualysguard_password"

2. **Configure Environment Variables for enabling proxy.Set Proxy Environment Variables (Optional: if creating a Containerized Scanner with Proxy)**
   Export the required proxy variables to configure proxy settings for the scanner:

   ```shell
   export TF_VAR_https_proxy_user="your_proxy_user"
   export TF_VAR_https_proxy_pass="your_proxy_password"
   export TF_VAR_https_proxy_host="your_proxy_host"

3. **Execute terraform command for creation of Containerized Scanner resources**
   Run the following Terraform commands to initialize, plan, and apply the configuration:
   ```shell
   terraform init 
   terraform plan -var-file=<PATH_TO_TFVARS_FILE>
   terraform apply -var-file=<PATH_TO_TFVARS_FILE>
   ```

# QCSA Image Scanner Configuration Parameters

| Parameter             | Input Value                                    | Description                                                                                   |
|-----------------------|------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `image_id`            |                                               | ID of the QCSA image. Prerequisite: the image must be configured on the Docker host. See [Qualys Docs](https://docs.qualys.com/en/scanner/qcsa/create_qcs/qcsa_image_config.htm) for configuration instructions. |
| `deployment_type`     | `resource_limited` or `resource_unlimited`                       | Specifies the scanner type. Scanning capacity varies based on memory, swap, and CPUs allocated, with options for `resource_limited` or `resource_unlimited`. |
| `container_name`      | `Valid container name`                         | Name of the container(s). `-container_count` will be appended to create multiple containers, e.g., `container_name-1`. |
| `container_count`     | `Number of containers to create`               | Number of containers to create. This must be greater than the previous count from prior executions. |
| `private_space_path`  | `Default: "/usr"`                     | Base directory path for the private space. |
| `shared_space_path`  | `Default: "/usr"`                        | Base directory path for the shared space. |
| `qualysguard_url`     | `QualysGuard URL`                              | URL to access QualysGuard. |
| `friendly_name`       |                        | Custom name for each scanner in QWeb. If left empty, defaults to `container_name`. `-container_count` will be appended for multiple containers, e.g., `friendly_name-1`. |
| `memory`              | `Default: "1024M"`                             | Memory allocated to the scanner container; required when `deployment_type` is `Limited`. |
| `memory_swap`         | `Default: "2048M"`                             | Total memory (memory + swap) allocated to the scanner container; required when `deployment_type` is `Limited`. |
| `cpus`                | `Default: "1"`                                 | Number of CPUs allocated to the scanner container; required when `deployment_type` is `Limited`. |
| `custom_root_CA`      | `true` / `false`                               | Configures custom root certificate on Docker host. See [Qualys Docs](https://docs.qualys.com/en/scanner/qcsa/create_qcs/custom_parameters_cs.htm) for details. |
| `enable_proxy`        | `true` / `false`                               | If `true`, creates a containerized scanner with proxy. Proxy environment variables must be set before execution. See [proxy configuration](https://docs.qualys.com/en/scanner/qcsa/create_qcs/custom_parameters_cs.htm#Containerized_Scanner_with_proxy_1). |
| `polling_interval`    | Numeric (in seconds)                           |To update the default interval in which the Containerized Scanner syncs with Qualys Platform Servers and checks for Containerized Scanner jobs (scan, shutdown). Valid range: 30-180 seconds. Default is 30 seconds. |
| `update_interval_min` | Numeric (in minutes)                           | To update the default interval in which the Containerized Scanner checks for Qualys Scanning Engine Packages updates.Valid range: 30-240 minutes. Default is 30 minutes. |
| `refresh_interval_min`| Numeric (in minutes)                           | To update the default interval in which the Scanner syncs with the Qualys Platform. Valid range: 10-360 minutes. Default is 10 minutes. |
| `enable_ipv6`         | `true` / `false`                               | Enables IPv6 support on containerized scanners. |
| `create_ipv6_network` | `true` / `false`                               | If `true`, creates a new IPv6 network. To use an existing network, set `false` and provide the existing network name in `ipv6_net_name`. |
| `subnet_range`        | `Default: "2001:db8::/64"`                    | IPv6 subnet range for a new network. Leave empty if using an existing network. |
| `ipv6_net_name`       |                                    | Name of the IPv6 network, either new name or existing  name. |
| `stop_containers`     | `true` / `false`                               | When set to `true`, this setting initiates the stop action terminating the containers. If any scanner is running an ongoing scan, the process will halt and exit. The stop actions will only complete successfully if no scans are in progress across all scanners created using the template. |
| `stop_and_delete_container_scanners`     | `true` / `false`                               | When set to `true`, this setting initiates the stop and delete process. The stop action terminates the containers, while the delete action removes the scanner containers created on qweb. If any scanner is running an ongoing scan, the process will halt and exit. The stop and delete actions will only complete successfully if no scans are in progress across all scanners created using the template.|

