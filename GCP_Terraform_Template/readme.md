# Deploy Qualys Virtual Scanner Appliance on Google Cloud

## GCP Template Files

- [main.tf](./main.tf)
- [provider.tf](./provider.tf)
- [variables.tf](./variables.tf)
- [version.tf](./version.tf)

## Deploy using Terraform

### Pre-requisites

1. **For Windows Users**: Install Windows Subsystem for Linux (WSL). For detailed installation steps, refer to the [official documentation](https://learn.microsoft.com/en-us/windows/wsl/install).
2. **Terraform Installation**: Install Terraform by following the instructions provided in the [Official Terraform documentation](https://developer.hashicorp.com/terraform/install).

### STEP 1

#### Export Environment Variables for QualysGuard Authentication

```shell
export QUALYSGUARD_LOGIN="your_qualysguard_username"
export QUALYSGUARD_PASSWORD="your__qualysguard_password"
```

Execute the following script:

./get_activation_token.sh <PATH_TO_TFVARS_FILE>

Example:
./get_activation_token.sh example/existing_resource.tfvars

### STEP 2

#### See parameter file examples in the 'example' directory

```shell
terraform init 
terraform plan -var-file=<PATH_TO_TFVARS_FILE>
terraform apply -var-file=<PATH_TO_TFVARS_FILE>
```

### Parameters

| Parameter                          | Input Value                                                                                           | Description                                                                                                                                                                                                                                                           |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `scanner_region`                   | Region Identifier                                                                                      | Region identifier for deployment (e.g., `us-west1`). [Learn more](https://cloud.google.com/compute/docs/regions-zones#:~:text=A%20zone%20is%20a%20deployment,is%20us%2Dcentral1%2Da%20.)                                        |
| `zone`                             | Zone Identifier                                                                                        | Zone identifier for deployment (e.g., `us-west1-b`). [Learn more](https://cloud.google.com/compute/docs/regions-zones#:~:text=A%20zone%20is%20a%20deployment,is%20us%2Dcentral1%2Da%20.)                                        |
| `scanner_name`                     | Scanner VM name                                                                                        | VM name on GCP can be 1-63 characters long and may contain alphanumerics, underscores, periods, and hyphens, and should match the regex `^[a-z]([-a-z0-9]*[a-z0-9])?`. [Learn more](https://cloud.google.com/compute/docs/naming-resources)                          |
| `scanner_machine_type`             | Scanner Machine Type                                                                                   | Any from the mentioned series (e.g., `e2-medium`). Available types: `E2 Series`, `N1 Series`, `N2 Series`, `N2D Series`, `C2 Series`, `C3 Series`, `M1 Series`, `M2 Series`, `A1 Series`, `F1 Series`, `G1 Series`. [Learn more](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes) |
| `project_name`                     | Existing Project Name                                                                                  | Project name on GCP can be 1-63 characters long and may contain alphanumerics, underscores, periods, and hyphens, and should match the regex `^[a-z]([-a-z0-9]*[a-z0-9])?`. [Learn more](https://cloud.google.com/resource-manager/docs/creating-managing-projects)     |
| `family_name`                      |                                                                                                        | Family Name for image. [Learn more](https://cloud.google.com/compute/docs/images/image-families-best-practices)                                                                                                                                                        |
| `key_file_path`                    |    Example:`test_key.json`                                                                                              | Key file path for service account. [Learn more](https://cloud.google.com/iam/docs/keys-create-delete#:~:text=You%20can%20use%20service%20account,%2Dprivate%2Dkey.json%20.)                                                                                           |
| `vm_count`                         | Number of VMs (Scanners) to create                                                                     |                                                                                                                                                                                                                                                                        |
| `virtual_network_new_or_existing`  | New or Existing Virtual Network                                                                        | Virtual network options for scanner VM. To create a new virtual network, provide `"new"` or `""`. To link the scanner with an existing virtual network, provide `"existing"` keyword.                                                                                   |
| `virtual_subnet_new_or_existing`   | New or Existing Subnet                                                                                 | Virtual subnet options for scanner VM. To create a new subnet, provide `"new"` or `""`. To link the scanner with an existing subnet, provide `"existing"` keyword.                                                                                                       |
| `image_uri`                        | Scanner image                                                                                          | Image options for scanner VM. Use the image URI extracted from Google Cloud Storage (GCS) bucket for a local image, or provide `"global_marketplace"` keyword to use the latest marketplace image.                                                                       |
| `virtual_network_name`             | Name of the virtual network instance                                                                   | This parameter can be used to provide a custom name when creating a new virtual network for the scanner VM during deployment. If not provided, Terraform will generate a name combining `"scannerName"` and a random string. For existing network, use name of existing network.                              |
| `virtual_subnet_name`              | Name of the virtual subnet instance                                                                    | This parameter can be used to provide a custom name when creating a new virtual subnet for the scanner VM during deployment. If not provided, Terraform will generate a name combining `"scannerName"` and a random string. For existing subnet, use name of existing subnet.                                 |
| `default_firewall_rule`            | `true`/`false`                                                                                         | This parameter specifies whether to use the default firewall rule (`true` for yes, `false` for no).                                                                                                                                                                                                            |
| `assign_public_ip`                 | `true`/`false`                                                                                         | This parameter specifies whether to assign a public IPv4 address to the scanner VM (`true` for yes, `false` for no). Default value is false.                                                                                                                                                                  |
| `assign_ipv6_ip`                   | `true`/`false`                                                                                         | This parameter specifies whether to assign a public IPv6 address to the scanner VM (`true` for yes, `false` for no). Default value is false.                                                                                                                                                                   |
| `stack_type`                       | `IPV4_ONLY`/`IPV4_IPV6`                                                                                | IP stack type for network interface.For assign_public_ip=true, set stack_type=`IPV4_ONLY` or `IPV4_IPV6`.Default value is `IPV4_ONLY`                                                                                                                                                                                                                                                |
| `friendly_name`                        | Friendly name for scanners                            | Assign a friendly name to each scanner created on QWeb. The friendly_name will be a combination of a user-defined name (up to 19 characters) and a 13-character string consisting of the current Unix timestamp and the VM's vm_count index. Since QWeb has a 32-character limit for the friendly_name, the user-defined portion can be up to 19 characters. Example: qvsa-1234567890-0 |
| `proxy_url`                            | Valid proxy (optional)                                                                                 | The proxy server address, if applicable.                                                                                                                                                                                                                                                                       |
| `proxy_cidr_block`                 | Valid CIDR range                                                                                       | Valid CIDR range for security/firewall rules. Default value is "0.0.0.0/0".                                                                                                                                                                                                                                      |
| `proxy_ipv6_cidr_blocks`           | Valid IPv6 CIDR range                                                                                  | Valid IPv6 CIDR range for security/firewall rules. Default value is "::/0".                                                                                                                                                                                                                                      |
| `desired_status`                   | `RUNNING`/`TERMINATED`                                                                                 | Desired status of the instance.                                                                                                                                                                                                                                                                                |
| `network_tier`                     | `Premium`/`Standard`                                                                                   | Network tier for the VM instances.                                                                                                                                                                                                                                                                              |
| `qualysguard_url`                  | QualysGuard URL                                                                                        | The URL for accessing QualysGuard.                                                                                                                                                                                                                                                                             |
