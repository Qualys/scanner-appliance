# Deploy Qualys Virtual Scanner Appliance on Azure Cloud

## Azure Template Files

- [main.tf](./main.tf)
- [provider.tf](./provider.tf)
- [variables.tf](./variables.tf)
- [version.tf](./version.tf)

## Deploy using Terraform

### Prerequisite

1. **For Windows Users**: Install Windows Subsystem for Linux (WSL). For detailed installation steps, refer to the [official documentation](https://learn.microsoft.com/en-us/windows/wsl/install).
2. **Terraform Installation**: Install Terraform by following the instructions provided in the [official terraform documentation](https://developer.hashicorp.com/terraform/install).
3. **Download Azure CLI**: Install Azure CLI for executing VM start and stop, refer to the [official Azure CLI installation link](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

### STEP 1

#### Export Environment Variables for QualysGuard and Azure Authentication

```shell
export QUALYSGUARD_LOGIN="your_qualysguard_username"
export QUALYSGUARD_PASSWORD="your__qualysguard_password"
export ARM_SUBSCRIPTION_ID="your_azure_subscription_id"
export ARM_CLIENT_ID="your_azure_client_id"
export ARM_CLIENT_SECRET="your_azure_client_secret"
export ARM_TENANT_ID="your_azure_tenant_id"
```
#### Export Environment Variables for enabling proxy having special character
```shell
export proxy_url='\\@-_012345._-@ABCabc\.\:.123.abc.XYZexample.com:8080'
```
Execute the following script:

path_to_get_activation_token_file <PATH_TO_TFVARS_FILE>

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

| Parameter                             | Description                                           | Details |
| -------------------------------------- | ----------------------------------------------------- | ------- |
| `location`                             | Location identifier                                   | Location identifier for deployment (example: `eastus`). [Learn more](https://azure.microsoft.com/en-in/global-infrastructure/locations) |
| `vm_count`                             | Number of scanner VMs to create                       | N/A     |
| `scanner_name`                         | Virtual Scanner Name                                  | VM name on Azure can be 1-63 characters long and may contain alphanumerics, underscores, periods, and hyphens but cannot contain special characters. It should match the regex `^[a-z]([-a-z0-9]*[a-z0-9])?`. |
| `start_vm`                             | True/False                                            | True will execute an Azure CLI command to start the scanner VMs. |
| `stop_vm`                              | True/False                                            | True will execute an Azure CLI command to stop the scanner VMs. |
| `network_interface_name`               | Name of the network interface                         | Provide a custom name for the network interface resource for the scanner VM. |
| `resource_group_name`                  | Existing Resource group name                          | Existing resource group name.|
| `virtual_network_name`                 | Existing virtual network name                         | Existing virtual network name. |
| `storage_account_name`                 | Storage account name                                  | Name of existing storage account. |
| `os_disk_type`                         | OS disk type                                          | One of the following: `Premium_LRS`, `StandardSSD_LRS`, `Standard_LRS`. Premium Disk is recommended but only available with selected VM sizes. [Learn more](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disks-types) |
| `assign_public_ip`                     | True/False                                            | Assign IPv4 public IP to scanner VMs. Default is `false`. |
| `assign_ipv6_public_ip`                | True/False                                            | Assign IPv6 public IP to scanner VMs. Default is `false`. |
| `image_resource`                       | Image for scanner VM                                  | Provide the image resource ID for locally stored image, for example: /subscriptions/123456da1-7e99-4eb9-9c0a-9bcb465f4e30/resourceGroups/Scanner-RG/providers/Microsoft.Compute/images/qVSA-Azure.x86_64-3.10.72-2, or use 'global_marketplace' to specify the latest marketplace image. |
| `friendly_name`                        | Friendly name for scanners                            | Assign a friendly name to each scanner created on QWeb. The friendly_name will be a combination of a user-defined name (up to 19 characters) and a 13-character string consisting of the current Unix timestamp and the VM's vm_count index. Since QWeb has a 32-character limit for the friendly_name, the user-defined portion can be up to 19 characters. Example: qvsa-1234567890-0 |
| `proxy_url`                                | Valid proxy (optional)                                | The proxy server address, if applicable.If the proxy URL contains any special characters, pass proxy_url as an environment variable. Example: export proxy_url='\\@-_012345._-@ABCabc\.\:.123.abc.XYZexample.com:8080' and skip passing proxy_url from .tfvars file. |
| `qualysguard_url`                      | QualysGuard URL                                       | The URL for accessing QualysGuard. |
