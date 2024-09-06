# Deploy Qualys Virtual Scanner Appliance on AWS Cloud

## AWS Template Files

- `main.tf`
- `provider.tf`
- `variables.tf`
- `version.tf`

## Deploy using Terraform

### Pre-requisite

1. **For Windows Users**: Install Windows Subsystem for Linux (WSL). For detailed installation steps, refer to the [official documentation](https://learn.microsoft.com/en-us/windows/wsl/install).
2. **Terraform Installation**: Install Terraform by following the instructions provided in the [official terraform documentation](https://developer.hashicorp.com/terraform/install).

### STEP 1

#### Export Environment Variables for QualysGuard and AWS Authentication

```shell
export QUALYSGUARD_LOGIN="your_qualysguard_username"
export QUALYSGUARD_PASSWORD="your__qualysguard_password"
export AWS_ACCESS_KEY_ID="your_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="your_AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="your_AWS_DEFAULT_REGION"
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

| Parameter               | Input Value                                                                                         | Description                                                                                                                                                                                                                   |
| ----------------------- | --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aws_region`            | Region Identifier                                                                                   | Region identifier for deployment (e.g., `us-east-1`). [Learn more](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)                                                           |
| `availability_zone`      | Availability Zones                                                                                 | Zone identifier for deployment (e.g., `us-east-1b`). [Learn more](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.AvailabilityZones)       |
| `scanner_instance_type`  | Instance Type                                                    | Any from mentioned series (e.g., `t2.micro`) [Learn more](https://aws.amazon.com/ec2/instance-types/)                                                                                                                                                                       |
| `scanner_name`                         | Virtual Scanner Name                                  | VM name on AWS can be 1-63 characters long and may contain alphanumerics, underscores, periods, and hyphens but cannot contain special characters. It should match the regex `^[a-z]([-a-z0-9]*[a-z0-9])?`. |
| `vm_count`                             | Number of scanner VMs to create                       | N/A     |
| `instance_state`                             |`running`/`stopped`                       | Desired state of Scanner VM's   |
| `vpc_name`               | VPC Name                                                                                           | Name of existing VPC.           |
| `virtual_subnet_name`    | Subnet Name                                                                                        | Name of existing subnet.                 |
| `default_security_group`         | true/false                                                          |Attatch default Security Group to scanner VMs. Default value is true.                                                                                                     |
| `security_group`         | Security group name                                                          |Existing Security group name. Provide default_security_group = false while using existing security group.                                                                                                    |
| `ami`                    | `global_marketplace` or AMI ID                                                                     | AMI for the scanner VM. Provide the AMI ID stored in the region or `"global_marketplace"` to use the latest marketplace image.                                                                                                  |
| `ignore_ami_changes`     | `true`/`false`                                                                                     | For  `ignore_ami_changes=true`, Terraform will ignore any new AMI ID updates. This allows you to update the configurations of the existing VM(s) that were created with the previous AMI. For `ignore_ami_changes=false`, Terraform will detect a new AMI ID, triggering the creation of new VM(s) with the updated AMI and desired variables(during terraform plan/apply).                                                                         |
| `friendly_name`                        | Friendly name for scanners                            | Assign a friendly name to each scanner created on QWeb. The friendly_name will be a combination of a user-defined name (up to 19 characters) and a 13-character string consisting of the current Unix timestamp and the VM's vm_count index. Since QWeb has a 32-character limit for the friendly_name, the user-defined portion can be up to 19 characters. Example: qvsa-1234567890-0 |
| `proxy_url`                  | Optional Variable                                                                                  | Valid proxy, if applicable.                                                                                                                                                                                                   |
| `proxy_cidr_block`                      | Valid cidr range                                                                              |Valid proxy cidr range for security/firewall rules.Default value is "0.0.0.0/0"                                                                                                                                                                                                                                                                    |
| `proxy_ipv6_cidr_blocks`                      | Valid IPv6 cidr range                                                                             |Valid proxy IPv6 cidr range for security/firewall rules.Default value is "::/0"                                                                                                                                                                                                                                                                    |
| `assign_public_ip`       | true/false                                                                               | This parameter specifies whether to assign a public IPv4 address to the scanner VM (`true` for yes, `false` for no).Default value is false.                                                                                                                                                                                        |
| `assign_ipv6_public_ip`  | true/false                                                                                  | This parameter specifies whether to assign a public IPv6 address to the scanner VM (`true` for yes, `false` for no). Default value is false.                                                               |

### Note

There is an open bug which doesn't prevent IPv6 assignment even though `ipv6_address_count=0` is set: <https://github.com/hashicorp/terraform-provider-aws/issues/20025>
