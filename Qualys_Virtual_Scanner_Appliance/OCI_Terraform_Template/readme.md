# Deploy Qualys Virtual Scanner Appliance on OCI

## OCI Template Files

- `main.tf`
- `provider.tf`
- `variables.tf`
- `version.tf`

## Deploy using Terraform

### Prerequisites

1. **For Windows Users**: Install Windows Subsystem for Linux (WSL). For detailed installation steps, refer to the [official documentation](https://learn.microsoft.com/en-us/windows/wsl/install).
2. **Terraform Installation**: Install Terraform by following the instructions provided in the [official terraform documentation](https://developer.hashicorp.com/terraform/install).

### STEP 1

### Generate and Configure Your OCI API Key
If you don't already have an OCI API Private Key and Fingerprint, follow these steps to create and configure them:  
&nbsp;&nbsp;&nbsp;&nbsp;1) Log in to your OCI Console.   
&nbsp;&nbsp;&nbsp;&nbsp;2) Click on your `Profile` icon (top-right corner), then select `User Settings`.  
&nbsp;&nbsp;&nbsp;&nbsp;3) Under Resources on the left sidebar, click `API Keys`.  
&nbsp;&nbsp;&nbsp;&nbsp;4) Click `Add API Key`.  
&nbsp;&nbsp;&nbsp;&nbsp;5) In the dialog:   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;i) Click `Generate API Key Pair`.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ii) Click `Download Private Key` and save it securely on your machine (e.g., /root/.oci/private_key.pem).  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;iii) Click `Add` to complete the process.  

Copy the Fingerprint that is displayed after adding the key — you will need this for configuration.

### STEP 2

#### Export Environment Variables for QualysGuard and OCI Authentication
```shell
export QUALYSGUARD_LOGIN="your_qualysguard_username"
export QUALYSGUARD_PASSWORD="your__qualysguard_password"
export TF_VAR_tenancy_ocid="your_OCI_tenacy_id "
export TF_VAR_user_ocid="your_OCI_user_id"
export TF_VAR_fingerprint="OCI_fingerprint_of_your_API_key."
```
#### Export Environment Variables for enabling proxy having special character
```shell
export proxy_url='\\@-_012345._-@ABCabc\.\:.123.abc.XYZexample.com:8080'
```

Execute the following script:

./get_activation_token.sh <PATH_TO_TFVARS_FILE>

Example:
./get_activation_token.sh example/existing_resource.tfvars

### STEP 3

#### See parameter file examples in the 'example' directory

```shell
terraform init 
terraform plan -var-file=<PATH_TO_TFVARS_FILE>
terraform apply -var-file=<PATH_TO_TFVARS_FILE>
```

### Parameters

| Parameter               | Input Value                                                                                         | Description                                                                                                                                                                                                                   |
| ----------------------- | --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `oci_region`            | Region Identifier                                                                                   | Region identifier for deployment (e.g., `us-ashburn-1`). [Learn more](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)                                                           |
| `availability_domain`      | Availability Domain                                                                                 | Domain identifier for deployment (e.g., `Lhkx:US-ASHBURN-AD-1`). [Learn more](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)       |
| `shape`  | Shape of Scanner                                                     | Any from mentioned series (e.g., `VM.Standard.E5.Flex`) [Learn more](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)                                                                                                                                                                       |
| `scanner_name`                         | Virtual Scanner Name                                  | VM name on OCI can be 1-63 characters long and may contain alphanumerics, underscores, periods, and hyphens. It should match the regex `^[a-z]([-a-z0-9]*[a-z0-9])?`. |
| `vm_count`                             | Number of scanner VMs to create                       | N/A     |
| `memory_in_gbs`                             | Memory (in GBs) | Amount of memory (in GBs) to allocate to scanner.<br> `Note`: Recommended OCPU-to-memory ratio is 1:4 (SMT enabled) or 1:2 (SMT disabled). |
| `ocpus`                             | Number of OCPUs                     | Specifies the number of Oracle CPUs (OCPUs) to allocate for the scanner.<br>With SMT enabled, 1 OCPU provides 2 vCPUs; with SMT disabled, 1 OCPU provides 1 vCPU.<br> `Note`: Recommended OCPU-to-memory ratio is 1:4 (SMT enabled) or 1:2 (SMT disabled). |
| `subnet_id`    | Subnet ID                                                                                        | ID of existing subnet.                 |                    |
| `image_ocid`                    | Image ID                                                                     | For deploying a custom image, use image ID.<br>For deploying a marketplace image, use `global_marketplace`.                                                                                                   |
| `compartment_ocid`     |     Compartment ID                                                                                 | ID of the compartment where the VM will be deployed.                                                                         |
| `friendly_name`                        | Friendly name for scanners                            | Assign a friendly name to each scanner created on QWeb. The friendly_name will be a combination of a user-defined name (up to 19 characters) and a 13-character string consisting of the current Unix timestamp and the VM's vm_count index. Since QWeb has a 32-character limit for the friendly_name, the user-defined portion can be up to 19 characters. Example: qvsa-1234567890-0 |
| `proxy_url` | Optional Variable | A valid proxy URL, if applicable. If the proxy URL contains any special characters, pass proxy_url as an environment variable. Example: export proxy_url='\\@-_012345._-@ABCabc\.\:.123.abc.XYZexample.com:8080' and skip passing proxy_url from .tfvars file.
| `assign_public_ip`       | true/false                                                                               | This parameter specifies whether to assign a public IPv4 address to the scanner VM (`true` for yes, `false` for no).Default value is false.                                                                                                                                                                                        |
| `assign_ipv6_public_ip`  | true/false                                                                                  | This parameter specifies whether to assign a public IPv6 address to the scanner VM (`true` for yes, `false` for no). Default value is false.                                                               |
| `platform_type`  | name of platform type                                                                                | The type of platform to use for the instance (AMD_VM, INTEL_VM, ARM_VM)  
| `enable_smt`  | true/false                                                                                  | Controls whether Simultaneous Multithreading (SMT) is enabled on the instance.<br> `true`: SMT is enabled — each OCPU gives 2 vCPUs.<br> `false`: SMT is disabled — each OCPU gives 1 vCPU.<br> `Note`: Qualys recommends disabling SMT (enable_smt: false)
| `legacy_imds_endpoints_disabled`  | true/false                                                                                  |   Controls whether legacy instance metadata service (IMDSv1) endpoints are disabled. For input `true`: IMDSv1 is disabled — only IMDSv2 is available (more secure; requires Authorization header). For input `false`: IMDSv1 is enabled — both IMDSv1 and IMDSv2 are available, allowing backward compatibility.<br>`Note`: Qualys recommends using IMDSv2 (legacy_imds_endpoints_disabled: true)