variable "aws_region" {
  type        = string
  description = <<EOT
Input: Region
Description: Region for scanner deployment (example: us-east-1)
Learn more: https://docs.aws.amazon.com/whitepapers/latest/get-started-documentdb/aws-regions-and-availability-zones.html
EOT
}

variable "availability_zone" {
  type        = string
  description = <<EOT
Input: Availability zone
Description: Availability zone (example: us-east-1b)
Learn more: https://docs.aws.amazon.com/whitepapers/latest/get-started-documentdb/aws-regions-and-availability-zones.html
EOT
}

variable "scanner_name" {
  type        = string
  description = <<EOT
Input: Scanner VM name
Description: VM name on AWS can be 1-63 characters long and may contain alphanumerics, underscores, periods, and hyphens but cannot contain special characters /\"[]:|<>+=;,?*@&. It should not begin with an underscore (_) or end with a period (.) or hyphen (-). Must match the regular expression: ^[a-z]([-a-z0-9]*[a-z0-9])?
EOT
  validation {
    condition     = length(var.scanner_name) >= 1 && length(var.scanner_name) <= 63
    error_message = "Scanner name must be between 1 and 63 characters long."
  }
}

variable "scanner_instance_type" {
  type        = string
  description = <<EOT
Input: Scanner Instance Type
Description: Choose an appropriate instance type from allowed values for EC2.
Learn more: https://aws.amazon.com/ec2/instance-types/
EOT
}

variable "vpc_name" {
  type        = string
  description = <<EOT
Input: Name of the VPC
Learn more: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
EOT
}

variable "virtual_subnet_name" {
  type        = string
  description = <<EOT
Input: Name of the virtual subnet
Learn more: https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html
EOT
}

variable "ami" {
  type        = string
  description = <<EOT
Input: 
  (input_1) Local AMI ID 
  (input_2) 'global_marketplace' 
Description: Provide a local AMI ID or 'global_marketplace' for latest marketplace AMI.
EOT
}

variable "security_group" {
  type        = string
  description = <<EOT
Input: Name of an existing security group
Learn more: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html
EOT
  default     = ""
}

variable "qualysguard_url" {
  type        = string
  description = "QualysGuard URL for scanner configuration."
}

variable "friendly_name" {
  type        = string
  description = "Friendly name for the scanner."
}

variable "proxy_url" {
  type        = string
  description = "Optional: Proxy URL for the scanner to use."
  default     = ""
}

variable "ignore_ami_changes" {
  type        = bool
  description = "Whether to ignore changes to the AMI ID."
  default     = false
}

variable "vm_count" {
  type        = number
  description = "Number of VMs to deploy."
  default     = 1
}

variable "default_security_group" {
  type        = bool
  description = "Whether to use the default security group."
  default     = true
}

variable "instance_state" {
  type        = string
  description = "Desired state of the instance (e.g., 'running')."
  default     = "running"
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether to assign a public IP4 address to the VM."
  default     = false
}

variable "assign_ipv6_public_ip" {
  type        = bool
  description = "Whether to assign an IPv6 address to the VM."
  default     = false
}

variable "proxy_cidr_block" {
  description = "CIDR block for the proxy"
  type        = string
  default     = "0.0.0.0/0"
}
variable "proxy_ipv6_cidr_blocks" {
  description = "IPv6 CIDR block for the proxy"
  type        = string
  default     = "::/0"
}
