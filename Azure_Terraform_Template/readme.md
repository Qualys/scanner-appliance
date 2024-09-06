# Deploy Qualys Virtual Scanner Appliance on Azure Cloud

## GCP Template Files

- [main.tf](./main.tf)
- [provider.tf](./provider.tf)
- [variables.tf](./variables.tf)
- [version.tf](./version.tf)

## Deploy using Terraform

### Pre-requisite

1. **For Windows Users**: Install Windows Subsystem for Linux (WSL). For detailed installation steps, refer to the [official documentation](https://learn.microsoft.com/en-us/windows/wsl/install).
2. **Terraform Installation**: Install Terraform by following the instructions provided in the [official terraform documentation](https://developer.hashicorp.com/terraform/install).

### STEP 1

#### Export Environment Variables for QualysGuard and Azure Authentication

```shell
export QUALYSGUARD_LOGIN="your_qualysguard_username"
export QUALYSGUARD_PASSWORD="your__qualysguard_password"
export azure_subscription_id="your_azure_subscription_id"
export azure_client_id="your_azure_client_id"
export azure_client_secret="your_azure_client_secret"
export azure_tenant_id="your_azure_tenant_id"
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
| `virtual_network_new_or_existing`      | New or Existing Virtual Network                       | `"new"` or "" for a new Vnet, `"existing"` for using an existing Vnet. |
| `virtual_resource_group_new_or_existing`| New or Existing Resource Group                        | `"new"` or "" for a new resource group, `"existing"` for using an existing resource group. |
| `resource_group_name`                  | Resource group name                                   | Custom name for a new or existing resource group. For `virtual_resource_group_new_or_existing="existing"`, provide the existing resource group name. |
| `virtual_network_name`                 | Existing virtual network name                         | Used with `virtual_network_new_or_existing="existing"`. Provide the existing virtual network name. |
| `storage_account_name`                 | Storage account name                                  | Name of existing storage account. |
| `new_virtual_network`                  | Name and address space of new virtual network         | Used with virtual_network_new_or_existing="new" or "".Custom name and address space. Defaults to `"default_vnet"` and `'10.0.0.0/24'` for IPv4, `'fd00:db8:deca::/64'` for IPv6 if not provided. |
| `new_subnet`                           | Name and address prefix of new subnet                 |Used with virtual_network_new_or_existing="new" or "".Custom name and address prefix. Defaults to `"default_subnet"` and `'10.0.0.0/24'` for IPv4, `'fd00:db8:deca::/64'` for IPv6 if not provided. |
| `os_disk_type`                         | OS disk type                                          | One of the following: `Premium_LRS`, `StandardSSD_LRS`, `Standard_LRS`. Premium Disk is recommended but only available with selected VM sizes. [Learn more](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disks-types) |
| `assign_public_ip`                     | True/False                                            | Assign IPv4 public IP to scanner VMs. Default is `false`. |
| `assign_ipv6_public_ip`                | True/False                                            | Assign IPv6 public IP to scanner VMs. Default is `false`. |
| `image_resource`                       | Image for scanner VM                                  | Provide image URI stored locally or use `'global_marketplace'` for the latest marketplace image. |
| `friendly_name`                        | Friendly name for scanners                            | Assign a friendly name to each scanner created on QWeb. The friendly_name will be a combination of a user-defined name (up to 19 characters) and a 13-character string consisting of the current Unix timestamp and the VM's vm_count index. Since QWeb has a 32-character limit for the friendly_name, the user-defined portion can be up to 19 characters. Example: qvsa-1234567890-0 |
| `proxy_url`                                | Valid proxy (optional)                                | The proxy server address, if applicable. |
| `proxy_cidr_block`                      | Valid cidr range                                                                              |Valid cidr range for security/firewall rules.Default value is "0.0.0.0/0"                                                                                                                                                                                                                                                                    |
| `proxy_ipv6_cidr_blocks`                      | Valid IPv6 cidr range                                                                             |Valid IPv6 cidr range for security/firewall rules.Default value is "::/0"                                                                                                                                                                                                                                                                    |
| `qualysguard_url`                      | QualysGuard URL                                       | The URL for accessing QualysGuard. |
